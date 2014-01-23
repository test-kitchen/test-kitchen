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

    # Basic shell provisioner.
    #
    # @author Chris Lundquist (<chris.ludnquist@github.com>)
    class Shell < Base

      default_config :script do |provisioner|
        provisioner.calculate_path("bootstrap.sh", :script)
      end
      expand_path_for :script

      default_config :data_path do |provisioner|
        provisioner.calculate_path("data")
      end
      expand_path_for :data_path

      def create_sandbox
        super
        prepare_data
        prepare_script
      end

      def init_command
        data = File.join(config[:root_path], "data")
        "#{sudo('rm')} -rf #{data} ; mkdir -p #{config[:root_path]}"
      end

      def run_command
        sudo(File.join(config[:root_path], File.basename(config[:script])))
      end

      protected

      def prepare_data
        return unless config[:data_path]

        info("Preparing data")
        debug("Using data from #{config[:data_path]}")

        tmpdata_dir = File.join(sandbox_path, "data")
        FileUtils.mkdir_p(tmpdata_dir)
        FileUtils.cp_r(Dir.glob("#{config[:data_path]}/*"), tmpdata_dir)
      end

      def prepare_script
        info("Preparing script")

        if config[:script]
          debug("Using script from #{config[:script]}")
          FileUtils.cp_r(config[:script], sandbox_path)
        else
          config[:script] = File.join(sandbox_path, "bootstrap.sh")
          info("#{File.basename(config[:script])} not found " +
            "so Kitchen will run a stubbed script. Is this intended?")
          File.open(config[:script], "wb") do |file|
            file.write(%{#!/bin/sh\necho "NO BOOTSTRAP SCRIPT PRESENT"\n})
          end
        end

        FileUtils.chmod(0755,
          File.join(sandbox_path, File.basename(config[:script])))
      end
    end
  end
end
