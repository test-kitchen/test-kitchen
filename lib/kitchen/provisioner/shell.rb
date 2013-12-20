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

      default_config :script do |provisioner|
        provisioner.calculate_path("bootstrap.sh", :script)
      end
      expand_path_for :script

      def create_sandbox
        super
        prepare_data
        prepare_script
      end

      def run_command
        sudo(File.join(config[:root_path], File.basename(config[:script])))
      end

      protected

      def prepare_script
        info("Preparing script")
        debug("Using script from #{config[:script]}")

        FileUtils.cp_r(config[:script], sandbox_path)
      end
    end
  end
end
