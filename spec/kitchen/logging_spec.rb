# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require_relative "../spec_helper"

require "kitchen/logging"

class LoggingDummy

  include Kitchen::Logging

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  class Logger

    METHODS = [:banner, :debug, :info, :warn, :error, :fatal]

    attr_reader(*(METHODS.map { |m| "#{m}_msg".to_sym }))

    METHODS.each do |meth|
      define_method(meth) do |*args|
        instance_variable_set("@#{meth}_msg", args.first)
      end
    end
  end
end

describe Kitchen::Logging do

  let(:logger)  { LoggingDummy::Logger.new }
  let(:subject) { LoggingDummy.new(logger) }

  LoggingDummy::Logger::METHODS.each do |meth|
    it "##{meth} calls method on logger" do
      subject.public_send(meth, "ping")

      logger.public_send("#{meth}_msg").must_equal "ping"
    end
  end
end
