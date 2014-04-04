# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'pathname'
require 'thread'

require 'kitchen/errors'
require 'kitchen/logger'
require 'kitchen/logging'
require 'kitchen/shell_out'
require 'kitchen/configurable'
require 'kitchen/util'

require 'kitchen/provisioner'
require 'kitchen/provisioner/base'
require 'kitchen/busser'
require 'kitchen/color'
require 'kitchen/collection'
require 'kitchen/config'
require 'kitchen/data_munger'
require 'kitchen/driver'
require 'kitchen/driver/base'
require 'kitchen/driver/ssh_base'
require 'kitchen/driver/proxy'
require 'kitchen/instance'
require 'kitchen/loader/yaml'
require 'kitchen/metadata_chopper'
require 'kitchen/platform'
require 'kitchen/state_file'
require 'kitchen/ssh'
require 'kitchen/suite'
require 'kitchen/version'

# Test Kitchen base module.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
module Kitchen

  class << self

    attr_accessor :logger
    attr_accessor :crashes
    attr_accessor :mutex

    # Returns the root path of the Kitchen gem source code.
    #
    # @return [Pathname] root path of gem
    def source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    def crashes?
      !crashes.empty?
    end

    def default_logger
      Logger.new(:stdout => STDOUT, :level => env_log)
    end

    def default_file_logger
      logfile = File.expand_path(File.join(".kitchen", "logs", "kitchen.log"))
      Logger.new(:stdout => STDOUT, :logdev => logfile, :level => env_log)
    end

    private

    def env_log
      level = ENV['KITCHEN_LOG'] && ENV['KITCHEN_LOG'].downcase.to_sym
      level = Util.to_logger_level(level) unless level.nil?
      level
    end
  end

  # Default log level verbosity
  DEFAULT_LOG_LEVEL = :info

  DEFAULT_TEST_DIR = "test/integration".freeze

  DEFAULT_LOG_DIR = ".kitchen/logs".freeze
end

# Initialize the base logger
Kitchen.logger = Kitchen.default_logger

# Setup a collection of instance crash exceptions for error reporting
Kitchen.mutex = Mutex.new
