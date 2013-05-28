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

    # Base class for a provisioner. A provisioner is responsible for generating
    # the commands necessary to install set up and use a configuration
    # management tool such as Chef and Puppet.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Logging

      def initialize(instance, config)
        @instance = instance
        @config = config
        @logger = instance.logger
      end

      def install_command ; end

      def init_command ; end

      def create_sandbox ; end

      def prepare_command ; end

      def run_command ; end

      def cleanup_sandbox ; end

      def home_path ; end

      protected

      attr_reader :instance, :logger, :config, :tmpdir

      def sudo(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end

      def kitchen_root
        config[:kitchen_root]
      end
    end
  end
end
