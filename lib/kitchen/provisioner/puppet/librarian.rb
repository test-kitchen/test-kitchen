# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>) Neill Turner (<neillwturner@gmail.com>)
#
# Copyright (C) 2013, Fletcher Nichol, Neill Turner
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

    module Puppet

      # Puppet module resolver that uses Librarian-Puppet and a Puppetfile to
      # calculate # dependencies.
      #
       class Librarian

        include Logging


        def initialize(puppetfile, path, logger = Kitchen.logger)
          @puppetfile   = puppetfile
          @path       = path
          @logger     = logger
        end

        def self.load!(logger = Kitchen.logger)
          load_librarian!(logger)
        end

        def resolve
          version = ::Librarian::Puppet::VERSION
          info("Resolving module dependencies with Librarian-Puppet #{version}...")
          debug("Using Puppetfile from #{puppetfile}")

          env = ::Librarian::Puppet::Environment.new(
            :project_path => File.dirname(puppetfile))
          env.config_db.local["path"] = path
          ::Librarian::Action::Resolve.new(env).run
          ::Librarian::Action::Install.new(env).run
        end

        attr_reader :puppetfile, :path, :logger

        def self.load_librarian!(logger)
          first_load = require 'librarian/puppet/environment'
          require 'librarian/action/resolve'
          require 'librarian/action/install'

          version = ::Librarian::Puppet::VERSION
          if first_load
            logger.debug("Librarian-Puppet #{version} library loaded")
          else
            logger.debug("Librarian-Puppet #{version} previously loaded")
          end
        rescue LoadError => e
          logger.fatal("The `librarian-puppet' gem is missing and must be installed" +
            " or cannot be properly activated. Run" +
            " `gem install librarian-puppet` or add the following to your" +
            " Gemfile if you are using Bundler: `gem 'librarian-puppet'`.")
          raise UserError,
            "Could not load or activate Librarian-Puppet (#{e.message})"
        end
      end
    end
  end
end
