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

module Kitchen

  module Error

    def self.formatted_trace(exception)
      arr = formatted_exception(exception).dup
      last = arr.pop
      if exception.respond_to?(:original) && exception.original
        arr += formatted_exception(exception.original, "Nested Exception")
        last = arr.pop
      end
      arr += ["Backtrace".center(22, "-"), exception.backtrace, last].flatten
      arr
    end

    def self.formatted_exception(exception, title = "Exception")
      [
        title.center(22, "-"),
        "Class: #{exception.class}",
        "Message: #{exception.message}",
        "".center(22, "-"),
      ]
    end
  end

  # Base exception class from which all Kitchen exceptions derive. This class
  # nests an exception when this class is re-raised from a rescue block.
  class StandardError < ::StandardError

    include Error

    attr_reader :original

    def initialize(msg, original = $!)
      super(msg)
      @original = original
    end
  end

  # Base exception class for all exceptions that are caused by user input
  # errors.
  class UserError < StandardError ; end

  # Base exception class for all exceptions that are caused by incorrect use
  # of an API.
  class ClientError < StandardError ; end

  # Base exception class for exceptions that are caused by external library
  # failures which may be temporary.
  class TransientFailure < StandardError ; end

  # Exception class for any exceptions raised when performing an instance
  # action.
  class ActionFailed < TransientFailure ; end

  # Exception class capturing what caused an instance to die.
  class InstanceFailure < TransientFailure ; end

  # Exception class raised when a cookbook's metadata is missing the name
  # attribute.
  class MissingCookbookName  < StandardError
    def initialize(name)
      @name = name
    end

    def to_s
      [
        "The metadata.rb does not define the 'name' key. Please add:",
        "",
        "  name '#{@name}'",
        "",
        "to the metadata.rb for '#{@name}' and try again."
      ].join("\n")
    end
  end

  def self.with_friendly_errors
    yield
  rescue Kitchen::InstanceFailure => e
    Kitchen.mutex.synchronize do
      handle_instance_failure(e)
    end
    exit 10
  rescue Kitchen::Error => e
    Kitchen.mutex.synchronize do
      handle_error(e)
    end
    exit 20
  end

  private

  def self.file_log(level, lines)
    Array(lines).each do |line|
      if Kitchen.logger.debug?
        Kitchen.logger.debug(line)
      else
        Kitchen.logger.logdev && Kitchen.logger.logdev.public_send(level, line)
      end
    end
  end

  def self.stderr_log(lines)
    Array(lines).each do |line|
      $stderr.puts(Color.colorize(">>>>>> #{line}", :red))
    end
  end

  def self.debug_log(lines)
    Array(lines).each { |line| Kitchen.logger.debug(line) }
  end

  def self.handle_instance_failure(e)
    stderr_log(e.message.split(/\s{2,}/))
    stderr_log(Error.formatted_exception(e.original))
    file_log(:error, e.message.split(/\s{2,}/).first)
    debug_log(Error.formatted_trace(e))
  end

  def self.handle_error(e)
    stderr_log(Error.formatted_exception(e))
    stderr_log("Please see .kitchen/logs/kitchen.log for more details\n")
    file_log(:error, Error.formatted_trace(e))
  end
end
