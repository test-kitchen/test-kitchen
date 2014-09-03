# -*- encoding: utf-8 -*-
#
# Author:: Salim Afiune (<salim@afiunemaya.com.mx>)
#
# Copyright (C) 2013, Salim Afiune
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

require "kitchen"

module Kitchen

  module Transport

    class Dummy < Kitchen::Transport::Base

      default_config :sleep, 1
      default_config :random_exit_code, 0

      # (see Base#exec)
      def execute(cmd)
        exit_code = execute_with_exit(cmd)
        if exit_code != 0
          info("Transport #{name} exited (#{exit_code}) for command: [#{cmd}]")
        end
      end

      def upload!(local, remote, options = {}, &progress)
        report(:upload, "#{local} => #{remote}")
      end

      def disconnect
        report(:disconnect)
      end

      def login_command(state)
        report(:login_command)
      end

      private

      def establish_connection
        report(:establish_connection)
      end

      def port
        config.fetch(:port, 1234)
      end

      def execute_with_exit(cmd)
        report(:exec_with_exit, cmd)
        config[:random_exit_code]
      end

      def test_connection
        report(:test_connection)
      end

      # Report what action is taking place, sleeping if so configured, and
      # possibly fail randomly.
      #
      # @param action [Symbol] the action currently taking place
      # @param state [Hash] the state hash
      # @api private
      def report(action, msg = "")
        what = action.capitalize
        info("[Dummy] #{what} #{msg} on Transport=#{name}")
        sleep_if_set
        debug("[Dummy] #{what} #{msg} completed (#{config[:sleep]}s).")
      end

      def sleep_if_set
        sleep(config[:sleep].to_f) if config[:sleep].to_f > 0.0
      end

    end
  end
end
