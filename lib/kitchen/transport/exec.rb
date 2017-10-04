# -*- encoding: utf-8 -*-
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

require "fileutils"

require "kitchen/shell_out"
require "kitchen/transport/base"
require "kitchen/version"

module Kitchen
  module Transport
    # Exec transport for Kitchen. This transport runs all commands locally.
    #
    # @since 1.19
    class Exec < Kitchen::Transport::Base
      kitchen_transport_api_version 1

      plugin_version Kitchen::VERSION

      def connection(state, &block)
        options = config.to_hash.merge(state)
        Kitchen::Transport::Exec::Connection.new(options, &block)
      end

      # Fake connection which just does local operations.
      class Connection < Kitchen::Transport::Base::Connection
        include ShellOut

        # (see Base#execute)
        def execute(command)
          return if command.nil?
          run_command(command)
        end

        # "Upload" the files by copying them locally.
        #
        # @see Base#upload
        def upload(locals, remote)
          FileUtils.mkdir_p(remote)
          Array(locals).each do |local|
            FileUtils.cp_r(local, remote)
          end
        end

      end
    end
  end
end
