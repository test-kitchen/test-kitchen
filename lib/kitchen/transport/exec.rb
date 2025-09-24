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

require "fileutils" unless defined?(FileUtils)

require_relative "../shell_out"
require_relative "base"
require_relative "../version"

module Kitchen
  module Transport
    # Exec transport for Kitchen. This transport runs all commands locally.
    #
    # @since 1.19
    class Exec < Kitchen::Transport::Base
      kitchen_transport_api_version 1

      plugin_version Kitchen::VERSION

      def connection(state, &block)
        options = connection_options(config.to_hash.merge(state))
        Kitchen::Transport::Exec::Connection.new(options, &block)
      end

      # Fake connection which just does local operations.
      class Connection < Kitchen::Transport::Base::Connection
        include ShellOut

        # (see Base#execute)
        def execute(command)
          return if command.nil?

          if host_os_windows?
            run_command(run_from_file_command(command))
            close
          else
            run_command(command)
          end
        end

        def close
          if host_os_windows?
            FileUtils.remove(exec_script_file)
          end
        end

        # "Upload" the files by copying them locally.
        #
        # @see Base#upload
        def upload(locals, remote)
          # evaluate $env:temp on Windows
          real_remote = remote.to_s == "$env:TEMP\\kitchen" ? kitchen_temp : remote
          FileUtils.mkdir_p(real_remote)
          Array(locals).each do |local|
            FileUtils.cp_r(local, real_remote)
          end
        end

        # (see Base#init_options)
        def init_options(options)
          super
          @instance_name = @options.delete(:instance_name)
          @kitchen_root = @options.delete(:kitchen_root)
        end

        private

        # @return [String] display name for the associated instance
        # @api private
        attr_reader :instance_name

        # @return [String] local path to the root of the project
        # @api private
        attr_reader :kitchen_root

        # Takes a long command and saves it to a file and uploads it to
        # the test instance. Windows has cli character limits.
        #
        # @param command [String] a long command to be saved and uploaded
        # @return [String] a command that executes the uploaded script
        # @api private
        def run_from_file_command(command)
          if logger.debug?
            debug("Creating exec script for #{instance_name} (#{exec_script_file})")
            debug("Executing #{exec_script_file}")
          end
          File.open(exec_script_file, "wb") { |file| file.write(command) }
          %{powershell -file "#{exec_script_file}"}
        end

        # @return [String] evaluated $env:temp variable
        # @api private
        def kitchen_temp
          "#{ENV["temp"]}/kitchen"
        end

        # @return [String] name of script using instance name
        # @api private
        def exec_script_name
          "#{instance_name}-exec-script.ps1"
        end

        # @return [String] file path for exec script to be run
        # @api private
        def exec_script_file
          File.join(kitchen_root, ".kitchen", exec_script_name)
        end

        def host_os_windows?
          case RbConfig::CONFIG["host_os"]
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            true
          else
            false
          end
        end
      end

      private

      # Builds the hash of options needed by the Connection object on construction.
      #
      # @param data [Hash] merged configuration and mutable state data
      # @return [Hash] hash of connection options
      # @api private
      def connection_options(data)
        opts = {
          instance_name: instance.name,
          kitchen_root: Dir.pwd,
        }
        opts
      end
    end
  end
end
