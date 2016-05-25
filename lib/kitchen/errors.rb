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

require "English"

module Kitchen

  # All Kitchen errors and exceptions.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Error

    # Creates an array of strings, representing a formatted exception,
    # containing backtrace and nested exception info as necessary, that can
    # be viewed by a human.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Kitchen::StandardError
    #     Message: Failure starting the party
    #     ---Nested Exception---
    #     Class: IOError
    #     Message: not enough directories for a party
    #     ------Backtrace-------
    #     nil
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @return [Array<String>] a formatted message
    def self.formatted_trace(exception, title = "Exception")
      arr = formatted_exception(exception, title).dup
      arr += formatted_backtrace(exception)

      if exception.respond_to?(:original) && exception.original
        arr += if exception.original.is_a? Array
          exception.original.map do |composite_exception|
            formatted_trace(composite_exception, "Composite Exception").flatten
          end
        else
          [
            formatted_exception(exception.original, "Nested Exception"),
            formatted_backtrace(exception)
          ].flatten
        end
      end
      arr.flatten
    end

    def self.formatted_backtrace(exception)
      if exception.backtrace.nil?
        []
      else
        [
          "Backtrace".center(22, "-"),
          exception.backtrace,
          "End Backtrace".center(22, "-")
        ]
      end
    end

    # Creates an array of strings, representing a formatted exception that
    # can be viewed by a human. Thanks to MiniTest for the inspiration
    # upon which this output has been designed.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Kitchen::StandardError
    #     Message: I have failed you
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @param title [String] a custom title for the message
    #   (default: `"Exception"`)
    # @return [Array<String>] a formatted message
    def self.formatted_exception(exception, title = "Exception")
      [
        title.center(22, "-"),
        "Class: #{exception.class}",
        "Message: #{exception.message}",
        "".center(22, "-")
      ]
    end
  end

  # Base exception class from which all Kitchen exceptions derive. This class
  # nests an exception when this class is re-raised from a rescue block.
  class StandardError < ::StandardError

    include Error

    # @return [::StandardError] the original (wrapped) exception
    attr_reader :original

    # Creates a new StandardError exception which optionally wraps an original
    # exception if given or detected by checking the `$!` global variable.
    #
    # @param msg [String] exception message
    # @param original [::StandardError] an original exception which will be
    #   wrapped (default: `$ERROR_INFO`)
    def initialize(msg, original = $ERROR_INFO)
      super(msg)
      @original = original
    end
  end

  # Base exception class for all exceptions that are caused by user input
  # errors.
  class UserError < StandardError; end

  # Base exception class for all exceptions that are caused by incorrect use
  # of an API.
  class ClientError < StandardError; end

  # Base exception class for exceptions that are caused by external library
  # failures which may be temporary.
  class TransientFailure < StandardError; end

  # Exception class for any exceptions raised when performing an instance
  # action.
  class ActionFailed < TransientFailure; end

  # Exception class capturing what caused an instance to die.
  class InstanceFailure < TransientFailure; end

  # Yields to a code block in order to consistently emit a useful crash/error
  # message and exit appropriately. There are two primary failure conditions:
  # an expected instance failure, and any other unexpected failures.
  #
  # **Note** This method may call `Kernel.exit` so may not return if the
  # yielded code block raises an exception.
  #
  # ## Instance Failure
  #
  # This is an expected failure scenario which could happen if an instance
  # couldn't be created, a Chef run didn't successfully converge, a
  # post-convergence test suite failed, etc. In other words, you can count on
  # encountering these failures all the time--this is Kitchen's worldview:
  # crash early and often. In this case a cleanly formatted exception is
  # written to `STDERR` and the exception message is written to
  # the common Kitchen file logger.
  #
  # ## Unexpected Failure
  #
  # All other forms of `Kitchen::Error` exceptions are considered unexpected
  # or unplanned exceptions, typically from user configuration errors, driver
  # or provisioner coding issues or bugs, or internal code issues. Given
  # a stable release of Kitchen and a solid set of drivers and provisioners,
  # the most likely cause of this is user configuration error originating in
  # the `.kitchen.yml` setup. For this reason, the exception is written to
  # `STDERR`, a full formatted exception trace is written to the common
  # Kitchen file logger, and a message is displayed on `STDERR` to the user
  # informing them to check the log files and check their configuration with
  # the `kitchen diagnose` subcommand.
  #
  # @raise [SystemExit] if an exception is raised in the yielded block
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

  # Writes an array of lines to the common Kitchen logger's file device at the
  # given severity level. If the Kitchen logger is set to debug severity, then
  # the array of lines will also be written to the console output.
  #
  # @param level [Symbol,String] the desired log level
  # @param lines [Array<String>] an array of strings to log
  # @api private
  def self.file_log(level, lines)
    Array(lines).each do |line|
      if Kitchen.logger.debug?
        Kitchen.logger.debug(line)
      else
        Kitchen.logger.logdev && Kitchen.logger.logdev.public_send(level, line)
      end
    end
  end

  # Writes an array of lines to the `STDERR` device.
  #
  # @param lines [Array<String>] an array of strings to log
  # @api private
  def self.stderr_log(lines)
    Array(lines).map { |line| ">>>>>> #{line}" }.each do |line|
      line = Color.colorize(line, :red) if Kitchen.tty?
      $stderr.puts(line)
    end
  end

  # Writes an array of lines to the common Kitchen debugger with debug
  # severity.
  #
  # @param lines [Array<String>] an array of strings to log
  # @api private
  def self.debug_log(lines)
    Array(lines).each { |line| Kitchen.logger.debug(line) }
  end

  # Handles an instance failure exception.
  #
  # @param e [StandardError] an exception to handle
  # @see Kitchen.with_friendly_errors
  # @api private
  def self.handle_instance_failure(e)
    stderr_log(e.message.split(/\s{2,}/))
    stderr_log(Error.formatted_exception(e.original))
    file_log(:error, e.message.split(/\s{2,}/).first)
    debug_log(Error.formatted_trace(e))
  end

  # Handles an unexpected failure exception.
  #
  # @param e [StandardError] an exception to handle
  # @see Kitchen.with_friendly_errors
  # @api private
  def self.handle_error(e)
    stderr_log(Error.formatted_exception(e))
    stderr_log("Please see .kitchen/logs/kitchen.log for more details")
    stderr_log("Also try running `kitchen diagnose --all` for configuration\n")
    file_log(:error, Error.formatted_trace(e))
  end
end
