# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

module Kitchen

  module Provisioner

    # Base class for a provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Configurable
      include Logging

      default_config :root_path, "/tmp/kitchen"
      default_config :sudo, true

      expand_path_for :test_base_path

      def initialize(config = {})
        init_config(config)
      end

      def finalize_config!(instance)
        super
        load_needed_dependencies!
        self
      end

      # Returns the name of this driver, suitable for display in a CLI.
      #
      # @return [String] name of this driver
      def name
        self.class.name.split('::').last
      end

      def init_command ; end

      def install_command ; end

      def prepare_command ; end

      def run_command ; end

      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{sandbox_path}")
      end

      def sandbox_path
        @sandbox_path || (raise ClientError, "Sandbox directory has not yet " +
          "been created. Please run #{self.class}#create_sandox before " +
          "trying to access the path.")
      end

      def cleanup_sandbox
        return if sandbox_path.nil?

        debug("Cleaning up local sandbox in #{sandbox_path}")
        FileUtils.rmtree(sandbox_path)
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

      def load_needed_dependencies! ; end

      def logger
        instance ? instance.logger : Kitchen.logger
      end

      def sudo(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end
    end
  end
end
