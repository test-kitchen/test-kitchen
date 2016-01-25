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

require "kitchen/command"

require "rubygems/spec_fetcher"
begin
  require "chef-config/config"
  require "chef-config/workstation_config_loader"
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # This space left intentionally blank.
end

module Kitchen

  module Command

    # Command to discover drivers published on RubyGems.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class DriverDiscover < Kitchen::Command::Base

      # Invoke the command.
      def call
        # We are introducing the idea of using the Chef configuration as a
        # unified config for all the ChefDK tools.  The first practical
        # implementation of this is 1 location to setup proxy configurations.
        if defined?(ChefConfig::WorkstationConfigLoader)
          ChefConfig::WorkstationConfigLoader.new(options[:chef_config_path]).load
        end
        ChefConfig::Config.export_proxies if defined?(ChefConfig::Config.export_proxies)

        specs = fetch_gem_specs.sort { |x, y| x[0] <=> y[0] }
        specs = specs[0, 49].push(["...", "..."]) if specs.size > 49
        specs = specs.unshift(["Gem Name", "Latest Stable Release"])
        print_table(specs, :indent => 4)
      end

      private

      # Fetches Kitchen-related RubyGems and returns an array of name/version
      # tuples.
      #
      # @return [Array<Array>] an array of name/version tuples
      # @api private
      def fetch_gem_specs
        req = Gem::Requirement.default
        dep = Gem::Deprecate.skip_during do
          Gem::Dependency.new(/kitchen-/i, req)
        end
        fetcher = Gem::SpecFetcher.fetcher

        if fetcher.respond_to?(:find_matching)
          fetch_gem_specs_pre_rubygems_2(fetcher, dep)
        else
          fetch_gem_specs_post_rubygems_2(fetcher, dep)
        end
      end

      # Fetches gem specs for RubyGems 2 and later.
      #
      # @param fetcher [Gem::SpecFetcher] a gemspec fetcher
      # @param dep [Gem::Dependency] a gem dependency object
      # @return [Array<Array>] an array of name/version tuples
      # @api private
      def fetch_gem_specs_post_rubygems_2(fetcher, dep)
        specs = fetcher.spec_for_dependency(dep, false)
        specs.first.map { |t| [t.first.name, t.first.version] }
      end

      # Fetches gem specs for pre-RubyGems 2.
      #
      # @param fetcher [Gem::SpecFetcher] a gemspec fetcher
      # @param dep [Gem::Dependency] a gem dependency object
      # @return [Array<Array>] an array of name/version tuples
      # @api private
      def fetch_gem_specs_pre_rubygems_2(fetcher, dep)
        specs = fetcher.find_matching(dep, false, false, false)
        specs.map(&:first).map { |t| t[0, 2] }
      end

      # Print out a display table.
      #
      # @api private
      def print_table(*args)
        shell.print_table(*args)
      end
    end
  end
end
