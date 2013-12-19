# -*- encoding: utf-8 -*-
#
# Author:: Chris Lundquist (<chris.lundquist@github.com>)
#
# Copyright (C) 2013, Chris Lundquist
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

require 'kitchen/provisioner/base'

module Kitchen

  module Provisioner

    # Chef Solo provisioner.
    #
    # @author Chris Lundquist (<chris.ludnquist@github.com>)
    class Shell < Base

      default_config :file do |provisioner|
        provisioner.calculate_path("bootstrap.sh", :file)
      end

      def run_command
        sudo(File.join(config[:root_path], File.basename(config[:file])))
      end

      def create_sandbox
        @tmpdir = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, @tmpdir)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{tmpdir}")

        shell_dir = File.join(tmpdir, "shell")

        FileUtils.mkdir_p(shell_dir)
        debug("Copying #{config[:file]} to #{shell_dir}")
        FileUtils.cp_r(config[:file], shell_dir)

        tmpdir
      end

      def cleanup_sandbox
        return if tmpdir.nil?

        debug("Cleaning up local sandbox in #{tmpdir}")
        FileUtils.rmtree(tmpdir)
      end

      def instance=(instance)
        @instance = instance
        expand_paths!
      end

      def calculate_path(path, type = :directory)
        base = config[:test_base_path]
        candidates = []
        candidates << File.join(base, instance.suite.name, path)
        candidates << File.join(base, path)
        candidates << File.join(Dir.pwd, path)

        candidates.find do |c|
          type == :directory ? File.directory?(c) : File.file?(c)
        end
      end

      protected

      attr_reader :tmpdir

      def expand_paths!
        [:file].each do |key|
          unless config[key].nil?
            config[key] = File.expand_path(config[key], config[:kitchen_root])
          end
        end
      end
    end
  end
end
