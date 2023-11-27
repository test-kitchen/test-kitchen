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

require_relative "../command"
require_relative "../diagnostic"

autoload :YAML, "yaml"

module Kitchen
  module Command
    # Command to log into to instance.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Diagnose < Kitchen::Command::Base
      # Invoke the command.
      def call
        instances = record_failure { load_instances }

        loader = record_failure { load_loader }

        puts YAML.dump(Kitchen::Diagnostic.new(
          loader:, instances:, plugins: plugins?
        ).read)
      end

      private

      def plugins?
        options[:all] || options[:plugins]
      end

      # Loads and returns instances if they are requested.
      #
      # @return [Array<Instance>] an array of instances or an empty array
      # @api private
      def load_instances
        if options[:all] || options[:instances]
          parse_subcommand(args.first)
        else
          []
        end
      end

      # Loads and returns loader configuration if it is requested.
      #
      # @return [Hash,nil] a hash or nil
      # @api private
      def load_loader
        @loader if options[:all] || options[:loader]
      end

      # Returns a hash with exception detail if an exception is raised in the
      # yielded block.
      #
      # @return [yield,Hash] the result of the yielded block or an error hash
      # @api private
      def record_failure
        yield
      rescue => e
        {
          error: {
            exception: e.inspect,
            message: e.message,
            backtrace: e.backtrace,
          },
        }
      end
    end
  end
end
