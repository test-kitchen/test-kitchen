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

require "kitchen/errors"
require "kitchen/logging"

module Kitchen

  module Provisioner

    module Chef

      # Chef cookbook resolver that uses Berkshelf and a Berksfile to calculate
      # dependencies.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class Berkshelf

        include Logging

        # Creates a new cookbook resolver.
        #
        # @param berksfile [String] path to a Berksfile
        # @param path [String] path in which to vendor the resulting
        #   cookbooks
        # @param logger [Kitchen::Logger] a logger to use for output, defaults
        #   to `Kitchen.logger`
        def initialize(berksfile, path, logger = Kitchen.logger)
          @berksfile  = berksfile
          @path       = path
          @logger     = logger
        end

        # Loads the library code required to use the resolver.
        #
        # @param logger [Kitchen::Logger] a logger to use for output, defaults
        #   to `Kitchen.logger`
        def self.load!(logger = Kitchen.logger)
          load_berkshelf!(logger)
        end

        # Performs the cookbook resolution and vendors the resulting cookbooks
        # in the desired path.
        def resolve
          version = ::Berkshelf::VERSION
          info("Resolving cookbook dependencies with Berkshelf #{version}...")
          debug("Using Berksfile from #{berksfile}")

          ::Berkshelf.ui.mute do
            if ::Berkshelf::Berksfile.method_defined?(:vendor)
              # Berkshelf 3.0 requires the directory to not exist
              FileUtils.rm_rf(path)
              ::Berkshelf::Berksfile.from_file(berksfile).vendor(path)
            else
              ::Berkshelf::Berksfile.from_file(berksfile).install(:path => path)
            end
          end
        end

        private

        # @return [String] path to a Berksfile
        # @api private
        attr_reader :berksfile

        # @return [String] path in which to vendor the resulting cookbooks
        # @api private
        attr_reader :path

        # @return [Kitchen::Logger] a logger to use for output
        # @api private
        attr_reader :logger

        # Load the Berkshelf-specific libary code.
        #
        # @param logger [Kitchen::Logger] the logger to use
        # @raise [UserError] if the library couldn't be loaded
        # @api private
        def self.load_berkshelf!(logger)
          first_load = require "berkshelf"

          version = ::Berkshelf::VERSION
          if first_load
            logger.debug("Berkshelf #{version} library loaded")
          else
            logger.debug("Berkshelf #{version} previously loaded")
          end
        rescue LoadError => e
          logger.fatal("The `berkshelf' gem is missing and must be installed" \
            " or cannot be properly activated. Run" \
            " `gem install berkshelf` or add the following to your" \
            " Gemfile if you are using Bundler: `gem 'berkshelf'`.")
          raise UserError,
            "Could not load or activate Berkshelf (#{e.message})"
        end
      end
    end
  end
end
