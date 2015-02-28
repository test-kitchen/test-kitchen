# -*- encoding: utf-8 -*-
#
# Author:: Fletcher (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require_relative "../../../spec_helper"

require "kitchen"
require "kitchen/transport/winrm/logging"

require "logger"

class ILog

  include Kitchen::Transport::Winrm::Logging

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end
end

class CustomSubject < ILog

  def log_subject
    "Wham"
  end
end

describe Kitchen::Transport::Winrm::Logging do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  describe "#debug" do

    it "nothing happens if logger is nil" do
      ILog.new(nil).debug("I'm cool")

      logged_output.string.must_equal ""
    end

    it "nothing happens if logger is above debug level" do
      logger.level = Logger::INFO
      ILog.new(logger).debug("I'm skipped")

      logged_output.string.must_equal ""
    end

    it "message is logged on debug level" do
      ILog.new(logger).debug("Debugging is fun")

      logged_output.string.must_match debug_line("[ILog] Debugging is fun")
    end

    it "block is called and used for debug level" do
      ILog.new(logger).debug { "Debugging is expensive" }

      logged_output.string.must_match debug_line("[ILog] Debugging is expensive")
    end

    it "message is used over block" do
      ILog.new(logger).debug("I win") { "I lose" }

      logged_output.string.must_match debug_line("[ILog] I win")
    end

    it "custom log subject is used if overridden" do
      CustomSubject.new(logger).debug("Bam")

      logged_output.string.must_match debug_line("[Wham] Bam")
    end
  end

  def debug_line(msg)
    %r{^D, .* : #{Regexp.escape(msg)}$}
  end
end
