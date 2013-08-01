# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'base64'
require 'digest'

module Kitchen

  # Command string generator to interface with Busser. The commands that are
  # generated are safe to pass to an SSH command or as an unix command
  # argument (escaped in single quotes).
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Busser

    attr_reader :test_root

    # Constructs a new Busser command generator, given a suite name.
    #
    # @param [String] suite_name name of suite on which to operate
    #   (**Required**)
    # @param [Hash] opts optional configuration
    # @option opts [TrueClass, FalseClass] :use_sudo whether or not to invoke
    #   sudo before commands requiring root access (default: `true`)
    def initialize(suite_name, opts = {})
      validate_options(suite_name)

      @test_root = opts.fetch(:test_root, DEFAULT_TEST_ROOT)
      @suite_name = suite_name
      @use_sudo = opts.fetch(:use_sudo, true)
    end

    # Returns a command string which installs Busser, and installs all
    # required Busser plugins for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to setup the test suite, or nil if no
    #   work needs to be performed
    def setup_cmd
      @setup_cmd ||= if local_suite_files.empty?
        nil
      else
        <<-INSTALL_CMD.gsub(/^ {10}/, '')
          bash -c '
          if ! #{sudo}#{ruby_binpath}/gem list busser -i >/dev/null ; then
            #{sudo}#{ruby_binpath}/gem install #{busser_gem} --no-rdoc --no-ri
          fi
          #{sudo}#{ruby_binpath}/busser setup
          #{sudo}#{busser_bin} plugin install #{plugins.join(' ')}'
        INSTALL_CMD
      end
    end

    # Returns a command string which transfers all suite test files to the
    # instance.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to transfer all suite test files, or
    #   nil if no work needs to be performed.
    def sync_cmd
      @sync_cmd ||= if local_suite_files.empty?
        nil
      else
        <<-INSTALL_CMD.gsub(/^ {10}/, '')
          bash -c '
          #{sudo}#{busser_bin} suite cleanup
          #{local_suite_files.map { |f| stream_file(f, remote_file(f, @suite_name)) }.join}
          #{helper_files.map { |f| stream_file(f, remote_file(f, "helpers")) }.join}'
        INSTALL_CMD
      end
    end

    # Returns a command string which runs all Busser suite tests for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to run the test suites, or nil if no
    #   work needs to be performed
    def run_cmd
      @run_cmd ||= local_suite_files.empty? ? nil : "#{sudo}#{busser_bin} test"
    end

    private

    DEFAULT_RUBY_BINPATH = "/opt/chef/embedded/bin".freeze
    DEFAULT_BUSSER_ROOT = "/opt/busser".freeze
    DEFAULT_TEST_ROOT = File.join(Dir.pwd, "test/integration").freeze

    def validate_options(suite_name)
      if suite_name.nil?
        raise ClientError, "Busser#new requires a suite_name"
      end

      if suite_name == 'helper'
        raise UserError,
          "Suite name invalid: 'helper' is a reserved directory name."
      end
    end

    def plugins
      Dir.glob(File.join(test_root, @suite_name, "*")).select { |d|
        File.directory?(d) && File.basename(d) != "data_bags"
      }.map { |d| "busser-#{File.basename(d)}" }.sort.uniq
    end

    def local_suite_files
      Dir.glob(File.join(test_root, @suite_name, "*/**/*")).reject do |f|
        f["data_bags"] || File.directory?(f)
      end
    end

    def helper_files
      Dir.glob(File.join(test_root, "helpers", "*/**/*"))
    end

    def remote_file(file, dir)
      local_prefix = File.join(test_root, dir)
      "$(#{sudo}#{busser_bin} suite path)/".concat(file.sub(%r{^#{local_prefix}/}, ''))
    end

    def stream_file(local_path, remote_path)
      local_file = IO.read(local_path)
      md5 = Digest::MD5.hexdigest(local_file)
      perms = sprintf("%o", File.stat(local_path).mode)[2, 4]
      stream_cmd = [
        "#{sudo}#{busser_bin}",
        "deserialize",
        "--destination=#{remote_path}",
        "--md5sum=#{md5}",
        "--perms=#{perms}"
      ].join(" ")

      <<-STREAMFILE.gsub(/^ {8}/, '')
        echo "Uploading #{remote_path} (mode=#{perms})"
        #{sudo}cat <<"__EOFSTREAM__" | #{sudo}#{stream_cmd}
        #{Base64.encode64(local_file)}
        __EOFSTREAM__
      STREAMFILE
    end

    def sudo
      @use_sudo ? "sudo -E " : ""
    end

    def ruby_binpath
      DEFAULT_RUBY_BINPATH
    end

    def busser_bin
      File.join(DEFAULT_BUSSER_ROOT, "bin/busser")
    end

    def busser_gem
      "busser"
    end
  end
end
