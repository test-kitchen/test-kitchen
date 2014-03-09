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

require 'kitchen/errors'
require 'kitchen/logging'

module Kitchen

  module Provisioner

    module Chef

      # Chef cookbook resolver that uses Librarian-Chef and a Cheffile to
      # calculate # dependencies.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class Librarian

        include Logging

        def initialize(cheffile, path, logger = Kitchen.logger)
          @cheffile   = cheffile
          @path       = path
          @logger     = logger
        end

        def self.load!(logger = Kitchen.logger)
          load_librarian!(logger)
        end

        def resolve
          version = ::Librarian::Chef::VERSION
          info("Resolving cookbook dependencies with Librarian-Chef #{version}...")
          debug("Using Cheffile from #{cheffile}")

          env = ::Librarian::Chef::Environment.new(
            :project_path => File.dirname(cheffile))
          env.config_db.local["path"] = path
          ::Librarian::Action::Resolve.new(env).run
          ::Librarian::Action::Install.new(env).run
        end

        attr_reader :cheffile, :path, :logger

        def self.load_librarian!(logger)
          first_load = require 'librarian/chef/environment'
          require 'librarian/action/resolve'
          require 'librarian/action/install'

          version = ::Librarian::Chef::VERSION
          if first_load
            logger.debug("Librarian-Chef #{version} library loaded")
          else
            logger.debug("Librarian-Chef #{version} previously loaded")
          end
        rescue LoadError => e
          logger.fatal("The `librarian-chef' gem is missing and must be installed" +
            " or cannot be properly activated. Run" +
            " `gem install librarian-chef` or add the following to your" +
            " Gemfile if you are using Bundler: `gem 'librarian-chef'`.")
          raise UserError,
            "Could not load or activate Librarian-Chef (#{e.message})"
        end
      end
    end
  end
end
