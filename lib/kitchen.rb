# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014 Fletcher Nichol
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

require "pathname"
require "thread"

require "kitchen/errors"
require "kitchen/logger"
require "kitchen/logging"
require "kitchen/shell_out"
require "kitchen/configurable"
require "kitchen/telemetry"
require "kitchen/util"

require "kitchen/provisioner"
require "kitchen/provisioner/base"
require "kitchen/color"
require "kitchen/collection"
require "kitchen/config"
require "kitchen/data_munger"
require "kitchen/driver"
require "kitchen/driver/base"
require "kitchen/driver/ssh_base"
require "kitchen/driver/proxy"
require "kitchen/instance"
require "kitchen/transport"
require "kitchen/transport/base"
require "kitchen/loader/yaml"
require "kitchen/metadata_chopper"
require "kitchen/platform"
require "kitchen/state_file"
require "kitchen/ssh"
require "kitchen/suite"
require "kitchen/verifier"
require "kitchen/verifier/base"
require "kitchen/version"

# Test Kitchen base module.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
module Kitchen
  class << self
    # @return [Logger] the common Kitchen logger
    attr_accessor :logger

    # @return [Mutex] a common mutex for global coordination
    attr_accessor :mutex

    # Returns the root path of the Kitchen gem source code.
    #
    # @return [Pathname] root path of gem
    def source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
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
        log_overwrite: log_overwrite
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
