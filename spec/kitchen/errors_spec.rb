#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require_relative "../spec_helper"

require "kitchen"
require "kitchen/errors"

describe Kitchen::Error do
  let(:exception) { Kitchen::StandardError.new("shoot") }

  describe ".formatted_exception" do
    it "returns an array of a formatted message" do
      _(Kitchen::Error.formatted_exception(exception))
        .must_equal([
          "------Exception-------",
          "Class: Kitchen::StandardError",
          "Message: shoot",
          "----------------------",
        ])
    end

    it "takes a customized title" do
      _(Kitchen::Error.formatted_exception(exception, "Trouble").first)
        .must_equal("-------Trouble--------")
    end
  end

  describe ".formatted_exception" do
    it "returns an array of a formatted message with a nil backtrace" do
      _(Kitchen::Error.formatted_trace(exception))
        .must_equal([
          "------Exception-------",
          "Class: Kitchen::StandardError",
          "Message: shoot",
          "----------------------",
        ])
    end

    it "returns an array containing the exception's backtrace" do
      raise Kitchen::StandardError, "shoot"
    rescue => e
      _(Kitchen::Error.formatted_trace(e)[5...-1]).must_equal e.backtrace
    end

    it "returns an array containing a nested exception, if given" do
      raise IOError, "no disk, yo"
    rescue
      e = Kitchen::StandardError.new("shoot")

      _(Kitchen::Error.formatted_trace(e))
        .must_equal([
          "------Exception-------",
          "Class: Kitchen::StandardError",
          "Message: shoot",
          "----------------------",
          "---Nested Exception---",
          "Class: IOError",
          "Message: no disk, yo",
          "----------------------",
        ])
    end

    it "returns an array when an error has more than one error in original" do
      error_array = []
      error_array << Kitchen::StandardError.new("one")
      error_array << Kitchen::StandardError.new("two")
      composite_error = Kitchen::StandardError.new("array", error_array)

      _(Kitchen::Error.formatted_trace(composite_error))
        .must_equal([
          "------Exception-------",
          "Class: Kitchen::StandardError",
          "Message: array",
          "----------------------",
          "-Composite Exception--",
          "Class: Kitchen::StandardError",
          "Message: one", "----------------------",
          "-Composite Exception--",
          "Class: Kitchen::StandardError",
          "Message: two",
          "----------------------"
        ])
    end
  end
end

describe Kitchen::StandardError do
  it "is a kind of Kitchen::Error" do
    _(Kitchen::StandardError.new("oops")).must_be_kind_of Kitchen::Error
  end

  it "by default, sets original exception to the last raised exception" do
    raise IOError, "crap"
  rescue
    original = Kitchen::StandardError.new("oops").original
    _(original).must_be_kind_of IOError
    _(original.message).must_equal "crap"
  end

  it "can embed an exception when constructing" do
    original = Kitchen::StandardError.new("durn", IOError.new("ack")).original
    _(original).must_be_kind_of IOError
    _(original.message).must_equal "ack"
  end
end

[
  Kitchen::UserError, Kitchen::ClientError, Kitchen::TransientFailure
].each do |klass|
  describe klass do
    it "is a kind of Kitchen::StandardError" do
      _(klass.new("oops")).must_be_kind_of Kitchen::StandardError
    end
  end
end

[
  Kitchen::ActionFailed, Kitchen::InstanceFailure
].each do |klass|
  describe klass do
    it "is a kind of Kitchen::TransientFailure" do
      _(klass.new("oops")).must_be_kind_of Kitchen::TransientFailure
    end
  end
end

describe Kitchen do
  describe ".with_friendly_errors" do
    let(:logger_io) { StringIO.new }
    let(:logger)    { Kitchen::Logger.new(logdev: logger_io) }

    before do
      Kitchen.stubs(:tty?).returns(true)
      @orig_stderr = $stderr
      $stderr = StringIO.new
      @orig_logger = Kitchen.logger
      Kitchen.logger = logger
    end

    after do
      $stderr = @orig_stderr
      Kitchen.logger = @orig_logger
    end

    describe "for instance failures" do
      def go_boom
        Kitchen.with_friendly_errors do
          raise IOError, "no stuff"
        rescue
          raise Kitchen::InstanceFailure, "cannot do that"
        end
      end

      it "exits with 10" do
        go_boom
      rescue SystemExit => e
        e.status.must_equal 10
      end

      it "prints a message on STDERR" do
        output = [
          ">>>>>> cannot do that",
          ">>>>>> ------Exception-------",
          ">>>>>> Class: IOError",
          ">>>>>> Message: no stuff",
          ">>>>>> ----------------------",
        ].map { |l| Kitchen::Color.colorize(l, :red) }.join("\n").concat("\n")

        begin
          go_boom
        rescue SystemExit
          _($stderr.string).must_equal output
        end
      end

      it "prints a message on STDERR without color" do
        Kitchen.stubs(:tty?).returns(false)
        output = [
          ">>>>>> cannot do that",
          ">>>>>> ------Exception-------",
          ">>>>>> Class: IOError",
          ">>>>>> Message: no stuff",
          ">>>>>> ----------------------",
        ].join("\n").concat("\n")

        begin
          go_boom
        rescue SystemExit
          _($stderr.string).must_equal output
        end
      end

      it "logs the exception message on the common logger's error severity" do
        go_boom
      rescue SystemExit
        logger_io.string.must_match(/ERROR -- Kitchen: cannot do that$/)
      end

      it "logs the exception message on debug, if set" do
        logger.level = ::Logger::DEBUG

        begin
          go_boom
        rescue SystemExit
          logger_io.string.must_match(/DEBUG -- Kitchen: cannot do that$/)
        end
      end
    end

    describe "for unexpected failures" do
      def go_boom
        Kitchen.with_friendly_errors do
          raise IOError, "wtf?"
        rescue
          raise Kitchen::StandardError, "ah crap"
        end
      end

      it "exits with 20" do
        go_boom
      rescue SystemExit => e
        e.status.must_equal 20
      end

      it "prints a message on STDERR" do
        output = [
          ">>>>>> ------Exception-------",
          ">>>>>> Class: Kitchen::StandardError",
          ">>>>>> Message: ah crap",
          ">>>>>> ----------------------",
          ">>>>>> Please see .kitchen/logs/kitchen.log for more details",
          ">>>>>> Also try running `kitchen diagnose --all` for configuration\n",
        ].map { |l| Kitchen::Color.colorize(l, :red) }.join("\n").concat("\n")

        begin
          go_boom
        rescue SystemExit
          _($stderr.string).must_equal output
        end
      end

      it "prints a message on STDERR without color" do
        Kitchen.stubs(:tty?).returns(false)
        output = [
          ">>>>>> ------Exception-------",
          ">>>>>> Class: Kitchen::StandardError",
          ">>>>>> Message: ah crap",
          ">>>>>> ----------------------",
          ">>>>>> Please see .kitchen/logs/kitchen.log for more details",
          ">>>>>> Also try running `kitchen diagnose --all` for configuration",
        ].join("\n").concat("\n")

        begin
          go_boom
        rescue SystemExit
          _($stderr.string).must_equal output
        end
      end

      it "logs the exception message on the common logger's error severity" do
        go_boom
      rescue SystemExit
        logger_io.string
          .must_match(/ERROR -- Kitchen: ------Exception-------$/)
        logger_io.string
          .must_match(/ERROR -- Kitchen: Class: Kitchen::StandardError$/)
        logger_io.string
          .must_match(/ERROR -- Kitchen: ------Backtrace-------$/)
      end

      it "logs the exception message on debug, if set" do
        logger.level = ::Logger::DEBUG

        begin
          go_boom
        rescue SystemExit
          logger_io.string
            .must_match(/DEBUG -- Kitchen: ------Exception-------$/)
          logger_io.string
            .must_match(/DEBUG -- Kitchen: Class: Kitchen::StandardError$/)
          logger_io.string
            .must_match(/DEBUG -- Kitchen: ------Backtrace-------$/)
        end
      end
    end
  end
end
