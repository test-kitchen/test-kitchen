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
    # Dummy transport for Kitchen. This transport does nothing but report what would
    # happen if this transport did anything of consequence. As a result it may
    # be a useful transport to use when debugging or developing new features or
    # plugins.
    class Dummy < Kitchen::Transport::Base
      kitchen_transport_api_version 1

      plugin_version Kitchen::VERSION

      default_config :sleep, 1
      default_config :random_exit_code, 0

      def connection(state, &block)
        options = config.to_hash.merge(state)
        Kitchen::Transport::Dummy::Connection.new(options, &block)
      end

      # TODO: comment
      class Connection < Kitchen::Transport::Base::Connection
        # (see Base#execute)
        def execute(command)
          report(:execute, command)
          if options[:random_exit_code] != 0
            info("Dummy exited (#{exit_code}) for command: [#{command}]")
          end
        end

        def upload(locals, remote)
          report(:upload, "#{locals.inspect} => #{remote}")
        end

        def download(remotes, local)
          report(:download, "#{remotes.inspect} => #{local}")
        end

        private

        # Report what action is taking place, sleeping if so configured, and
        # possibly fail randomly.
        #
        # @param action [Symbol] the action currently taking place
        # @param state [Hash] the state hash
        # @api private
        def report(action, msg = "")
          what = action.capitalize
          info("[Dummy] #{what} #{msg} on Transport=Dummy")
          sleep_if_set
          debug("[Dummy] #{what} #{msg} completed (#{options[:sleep]}s).")
        end

        def sleep_if_set
          sleep(options[:sleep].to_f) if options[:sleep].to_f > 0.0
        end
      end
    end
  end
end
