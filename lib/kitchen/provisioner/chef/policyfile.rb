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

require "shellwords"
require "rbconfig"

require "kitchen/errors"
require "kitchen/logging"
require "kitchen/shell_out"

module Kitchen

  module Provisioner

    module Chef

      # Chef cookbook resolver that uses Policyfiles to calculate dependencies.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class Policyfile

        include Logging
        include ShellOut

        # Creates a new cookbook resolver.
        #
        # @param policyfile [String] path to a Policyfile
        # @param path [String] path in which to vendor the resulting
        #   cookbooks
        # @param logger [Kitchen::Logger] a logger to use for output, defaults
        #   to `Kitchen.logger`
        def initialize(policyfile, path, logger: Kitchen.logger, always_update: false)
          @policyfile = policyfile
          @path       = path
          @logger     = logger
          @always_update = always_update
        end

        # Loads the library code required to use the resolver.
        #
        # @param logger [Kitchen::Logger] a logger to use for output, defaults
        #   to `Kitchen.logger`
        def self.load!(logger: Kitchen.logger)
          detect_chef_command!(logger)
        end

        # Performs the cookbook resolution and vendors the resulting cookbooks
        # in the desired path.
        def resolve
          info("Exporting cookbook dependencies from Policyfile #{path}...")
          run_command("chef export #{escape_path(policyfile)} #{escape_path(path)} --force")
        end

        # Runs `chef install` to determine the correct cookbook set and
        # generate the policyfile lock.
        def compile
          if always_update
            info("Updating policy lock using `chef update`")
            run_command("chef update #{escape_path(policyfile)}")
          end
          if File.exist?(lockfile)
            info("Installing cookbooks for Policyfile #{policyfile} using `chef install`")
          else
            info("Policy lock file doesn't exist, running `chef install` for "\
                 "Policyfile #{policyfile}...")
          end
          run_command("chef install #{escape_path(policyfile)}")
        end

        # Return the path to the lockfile corresponding to this policyfile.
        #
        # @return [String]
        def lockfile
          policyfile.gsub(/\.rb\Z/, ".lock.json")
        end

        private

        # @return [String] path to a Berksfile
        # @api private
        attr_reader :policyfile

        # @return [String] path in which to vendor the resulting cookbooks
        # @api private
        attr_reader :path

        # @return [Kitchen::Logger] a logger to use for output
        # @api private
        attr_reader :logger

        # @return [Boolean] If true, always update cookbooks in the policy.
        # @api private
        attr_reader :always_update

        # Ensure the `chef` command is in the path.
        #
        # @param logger [Kitchen::Logger] the logger to use
        # @raise [UserError] if the `chef` command is not in the PATH
        # @api private
        def self.detect_chef_command!(logger)
          unless ENV["PATH"].split(File::PATH_SEPARATOR).any? { |p|
            File.exist?(File.join(p, "chef"))
          }
            logger.fatal("The `chef` executable cannot be found in your " \
                         "PATH. Ensure you have installed ChefDK from " \
                         "https://downloads.chef.io and that your PATH " \
                         "setting includes the path to the `chef` comand.")
            raise UserError,
              "Could not find the chef executable in your PATH."
          end
        end

        # Escape spaces in a path in way that works with both Sh (Unix) and
        # Windows.
        #
        # @param path [String] Path to escape
        # @return [String]
        # @api private
        def escape_path(path)
          if RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
            # I know what you're thinking: "just use Shellwords.escape". That
            # method produces incorrect results on Windows with certain input
            # which would be a metacharacter in Sh but is not for one or more of
            # Windows command line parsing libraries. This covers the 99% case of
            # spaces in the path without breaking other stuff.
            if path =~ /[ \t\n\v"]/
              "\"#{path.gsub(/[ \t\n\v\"\\]/) { |m| "\\" + m[0] }}\""
            else
              path
            end
          else
            Shellwords.escape(path)
          end
        end
      end
    end
  end
end
