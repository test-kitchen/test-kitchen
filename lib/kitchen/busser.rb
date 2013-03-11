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
require 'net/https'

module Kitchen

  # Command string generator to interface with Kitchen Busser (kb). The
  # commands that are generated are safe to pass to an SSH command or as an
  # unix command argument (escaped in single quotes).
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Busser

    # Constructs a new busser command generator, given a suite name.
    #
    # @param [String] suite_name name of suite on which to operate
    #   (**Required**)
    # @param [Hash] opts optional configuration
    # @option opts [TrueClass, FalseClass] :use_sudo whether or not to invoke
    #   sudo before commands requiring root access (default: `true`)
    def initialize(suite_name, opts = { :use_sudo => true })
      validate_options(suite_name)

      @suite_name = suite_name
      @use_sudo = opts[:use_sudo]
    end

    # Returns a command string which installs the Kitchen Busser (kb), installs
    # all required kb plugins for the suite.
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
          #{sudo}#{ruby_bin} -e "$(cat <<"EOF"
          #{install_script}
          EOF
          )"
          #{sudo}#{kb_bin} install #{plugins.join(' ')}
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
          #{sudo}#{kb_bin} cleanup-suites
          #{local_suite_files.map { |f| stream_file(f, remote_file(f)) }.join}
        INSTALL_CMD
      end
    end

    # Returns a command string which runs all kb suite tests for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to run the test suites, or nil if no
    #   work needs to be performed
    def run_cmd
      @run_cmd ||= local_suite_files.empty? ? nil : "#{sudo}#{kb_bin} test"
    end

    private

    INSTALL_URL = "https://raw.github.com/opscode/kb/go".freeze
    DEFAULT_RUBY_BINPATH = "/opt/chef/embedded/bin".freeze
    DEFAULT_KB_ROOT = "/opt/kb".freeze
    DEFAULT_TEST_ROOT = File.join(Dir.pwd, "test/integration").freeze
    RESERVED_NAMES = ["data_bags", "roles"].freeze

    def validate_options(suite_name)
      raise ClientError, "Busser#new requires a suite_name" if suite_name.nil?
    end

    def install_script
      @install_script ||= begin
        uri = URI.parse(INSTALL_URL)
        http = Net::HTTP.new(uri.host, 443)
        http.use_ssl = true
        response = http.request(Net::HTTP::Get.new(uri.path))
        response.body
      end
    end

    def plugins
      [plugins_by_directory, plugins_by_extension].sort.uniq
    end

    def plugins_by_directory
      Dir.glob(File.join(test_root, @suite_name, "*")).select { |d|
        File.directory?(d) && !RESERVED_NAMES.include?(File.basename(d))
      }.map { |d| File.basename(d) }.sort.uniq
    end

    def plugins_by_extension
      Dir.glob(File.join(test_root, @suite_name, "*/**/*")).reject do |f|
        f["data_bags"] || File.directory?(f)
      end.map { |i| File.extname(i)[1..-1] }.sort.uniq
    end

    def local_suite_files
      Dir.glob(File.join(test_root, @suite_name, "*/**/*")).reject do |f|
        f["data_bags"] || File.directory?(f)
      end
    end

    def remote_file(file)
      local_prefix = File.join(test_root, @suite_name)
      "$(#{kb_bin} suitepath)/".concat(file.sub(%r{^#{local_prefix}/}, ''))
    end

    def stream_file(local_path, remote_path)
      local_file = IO.read(local_path)
      md5 = Digest::MD5.hexdigest(local_file)
      perms = sprintf("%o", File.stat(local_path).mode)[3, 3]
      kb_stream_file = "#{kb_bin} stream-file #{remote_path} #{md5} #{perms}"

      <<-STREAMFILE.gsub(/^ {8}/, '')
        echo "Uploading #{remote_path} (mode=#{perms})"
        cat <<"__EOFSTREAM__" | #{sudo}#{kb_stream_file}
        #{Base64.encode64(local_file)}
        __EOFSTREAM__
      STREAMFILE
    end

    def sudo
      @use_sudo ? "sudo " : ""
    end

    def ruby_bin
      File.join(DEFAULT_RUBY_BINPATH, "ruby")
    end

    def kb_bin
      File.join(DEFAULT_KB_ROOT, "bin/kb")
    end

    def test_root
      DEFAULT_TEST_ROOT
    end
  end
end
