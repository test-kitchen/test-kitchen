#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014 Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "pathname" unless defined?(Pathname)
require_relative "kitchen/errors"
require_relative "kitchen/logger"
require_relative "kitchen/logging"
require_relative "kitchen/shell_out"
require_relative "kitchen/configurable"
require_relative "kitchen/util"

require_relative "kitchen/provisioner"
require_relative "kitchen/provisioner/base"
require_relative "kitchen/color"
require_relative "kitchen/collection"
require_relative "kitchen/config"
require_relative "kitchen/data_munger"
require_relative "kitchen/driver"
require_relative "kitchen/driver/base"
require_relative "kitchen/driver/ssh_base"
require_relative "kitchen/driver/proxy"
require_relative "kitchen/instance"
require_relative "kitchen/lifecycle_hooks"
require_relative "kitchen/transport"
require_relative "kitchen/transport/base"
require_relative "kitchen/loader/yaml"
require_relative "kitchen/metadata_chopper"
require_relative "kitchen/platform"
require_relative "kitchen/state_file"
require_relative "kitchen/ssh"
require_relative "kitchen/suite"
require_relative "kitchen/verifier"
require_relative "kitchen/verifier/base"
require_relative "kitchen/version"
require "pry"
require "pry-nav"
# Test Kitchen base module.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
module Kitchen
  class << self
    # @return [Logger] the common Kitchen logger
    attr_accessor :logger

    # @return [Mutex] a common mutex for global coordination
    attr_accessor :mutex

    # @return [Mutex] a mutex used for Dir.chdir coordination
    attr_accessor :mutex_chdir

    # Returns the root path of the Kitchen gem source code.
    #
    # @return [Pathname] root path of gem
    def source_root
      @source_root ||= Pathname.new(File.expand_path("..", __dir__))
    end

    # Returns a default logger which emits on standard output.
    #
    # @return [Logger] a logger
    def default_logger
      Logger.new(stdout: $stdout, level: Util.to_logger_level(env_log))
    end

    # Returns a default file logger which emits on standard output and to a
    # log file.
    #
    # @param [Symbol] level logging level
    # @param [Boolean] log_overwrite logging level
    # @return [Logger] a logger
    def default_file_logger(level = nil, log_overwrite = nil)
      level ||= env_log
      log_overwrite = log_overwrite.nil? ? env_log_overwrite : log_overwrite
      log_location = File.expand_path(File.join(DEFAULT_LOG_DIR, "kitchen.log"))
      log_location = log_location.to_s

      Logger.new(
        stdout: $stdout,
        logdev: log_location,
        level: Util.to_logger_level(level),
        log_overwrite:
      )
    end

    # Returns whether or not standard output is associated with a terminal
    # device (tty).
    #
    # @return [true,false] is there a tty?
    def tty?
      $stdout.tty?
    end

    # Determine the default log level from an environment variable, if it is
    # set.
    #
    # @return [Symbol,nil] a log level or nil if not set
    # @api private
    def env_log
      ENV["KITCHEN_LOG"] && ENV["KITCHEN_LOG"].downcase.to_sym
    end

    # Determine the log overwriting logic from an environment variable,
    # if it is set.
    #
    # @return [Boolean,nil]
    # @api private
    def env_log_overwrite
      case ENV["KITCHEN_LOG_OVERWRITE"] && ENV["KITCHEN_LOG_OVERWRITE"].downcase
      when nil, ""
        nil
      when "false", "f", "no"
        false
      else
        true
      end
    end
  end

  # Default log level verbosity
  DEFAULT_LOG_LEVEL = :info

  # Overwrite the log file when Test Kitchen runs
  DEFAULT_LOG_OVERWRITE = true

  # Default base directory for integration tests, fixtures, etc.
  DEFAULT_TEST_DIR = "test/integration".freeze

  # Default base directory for instance and common log files
  DEFAULT_LOG_DIR = ".kitchen/logs".freeze
end

# Initialize the base logger
Kitchen.logger = Kitchen.default_logger

# Setup a collection of instance crash exceptions for error reporting
Kitchen.mutex = Mutex.new

# Initialize the mutex for Dir.chdir coordination
Kitchen.mutex_chdir = Mutex.new
