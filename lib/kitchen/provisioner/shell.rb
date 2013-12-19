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
    # @author Chris Lundquist (<chris.lundquist@github.com>)
    class Shell < Base
      attr_accessor :tmpdir
      default_config :file do |provisioner|
        provisioner.calculate_path('bootstrap.sh')
      end

      def run_command
        sudo(File.join(config[:root_path], config[:file]))
      end

      # XXX Not implementing this will upload '/*' to each host
      # Or try, and die on resolving bad symlinks
      def create_sandbox
        @tmpdir = Dir.mktmpdir
        debug("Created local sandbox in #{tmpdir}")
        shell_dir = File.join(tmpdir, "shell")

        FileUtils.mkdir_p(shell_dir)
        debug("Copying #{config[:file]} to #{shell_dir}")
        FileUtils.cp_r(config[:file], shell_dir)

        @tmpdir
      end

      def cleanup_sandbox
        return if tmpdir.nil?

        debug("Cleaning up local sandbox in #{tmpdir}")
        FileUtils.rmtree(tmpdir)
      end
    end
  end
end
