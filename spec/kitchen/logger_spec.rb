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

require "kitchen"

describe Kitchen::Logger do

  before do
    @orig_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stdout = @orig_stdout
  end

  def colorize(*args)
    Kitchen::Color.colorize(*args)
  end

  let(:opts) do
    { :color => :red, :colorize => true }
  end

  let(:logger) do
    Kitchen::Logger.new(opts)
  end

  it "sets the log level to :info by default" do
    logger.level.must_equal Kitchen::Util.to_logger_level(:info)
    logger.debug?.must_equal false
    logger.info?.must_equal true
    logger.error?.must_equal true
    logger.warn?.must_equal true
    logger.fatal?.must_equal true
  end

  it "sets a level at creation" do
    opts[:level] = Kitchen::Util.to_logger_level(:warn)

    logger.level.must_equal Kitchen::Util.to_logger_level(:warn)
    logger.info?.must_equal false
    logger.warn?.must_equal true
    logger.fatal?.must_equal true
  end

  it "sets a level after creation" do
    logger.level = Kitchen::Util.to_logger_level(:fatal)

    logger.level.must_equal Kitchen::Util.to_logger_level(:fatal)
    logger.warn?.must_equal false
    logger.fatal?.must_equal true
  end

  it "datetime_format is nil by default" do
    logger.datetime_format.must_equal nil
  end

  it "sets datetime_format after creation" do
    logger.datetime_format = "smart?"

    logger.datetime_format.must_equal "smart?"
  end

  it "sets progname to Kitchen by default" do
    logger.progname.must_equal "Kitchen"
  end

  it "sets progname at creation" do
    opts[:progname] = "Dream Theater"

    logger.progname.must_equal "Dream Theater"
  end

  it "sets progname after creation" do
    logger.progname = "MASTA"

    logger.progname.must_equal "MASTA"
  end

  describe "stdout-based logger" do

    let(:stdout) { StringIO.new }

    before { opts[:stdout] = stdout }

    it "sets up a simple STDOUT logger by default" do
      opts.delete(:stdout)
      logger.info("hello")

      $stdout.string.must_equal colorize("       hello", opts[:color]) + "\n"
    end

    it "sets up a simple STDOUT logger by default with no color" do
      opts[:colorize] = false
      opts.delete(:stdout)
      logger.info("hello")

      $stdout.string.must_equal "       hello\n"
    end

    it "accepts a :stdout option to redirect output" do
      logger.info("hello")

      stdout.string.must_equal colorize("       hello", opts[:color]) + "\n"
    end

    it "accepts a :stdout option to redirect output with no color" do
      opts[:colorize] = false
      logger.info("hello")

      stdout.string.must_equal "       hello\n"
    end

    describe "for severity" do

      before { opts[:level] = Kitchen::Util.to_logger_level(:debug) }

      it "logs to banner" do
        logger.banner("yo")

        stdout.string.must_equal colorize("-----> yo", opts[:color]) + "\n"
      end

      it "logs to banner with no color" do
        opts[:colorize] = false
        logger.banner("yo")

        stdout.string.must_equal "-----> yo\n"
      end

      it "logs to debug" do
        logger.debug("yo")

        stdout.string.must_equal colorize("D      yo", opts[:color]) + "\n"
      end

      it "logs to debug with no color" do
        opts[:colorize] = false
        logger.debug("yo")

        stdout.string.must_equal "D      yo\n"
      end

      it "logs to info" do
        logger.info("yo")

        stdout.string.must_equal colorize("       yo", opts[:color]) + "\n"
      end

      it "logs to info with no color" do
        opts[:colorize] = false
        logger.info("yo")

        stdout.string.must_equal "       yo\n"
      end

      it "logs to error" do
        logger.error("yo")

        stdout.string.must_equal colorize(">>>>>> yo", opts[:color]) + "\n"
      end

      it "logs to error with no color" do
        opts[:colorize] = false
        logger.error("yo")

        stdout.string.must_equal ">>>>>> yo\n"
      end

      it "logs to warn" do
        logger.warn("yo")

        stdout.string.must_equal colorize("$$$$$$ yo", opts[:color]) + "\n"
      end

      it "logs to warn with no color" do
        opts[:colorize] = false
        logger.warn("yo")

        stdout.string.must_equal "$$$$$$ yo\n"
      end

      it "logs to fatal" do
        logger.fatal("yo")

        stdout.string.must_equal colorize("!!!!!! yo", opts[:color]) + "\n"
      end

      it "logs to fatal with no color" do
        opts[:colorize] = false
        logger.fatal("yo")

        stdout.string.must_equal "!!!!!! yo\n"
      end

      it "logs to unknown" do
        logger.unknown("yo")

        stdout.string.must_equal colorize("?????? yo", opts[:color]) + "\n"
      end

      it "logs to unknown with no color" do
        opts[:colorize] = false
        logger.unknown("yo")

        stdout.string.must_equal "?????? yo\n"
      end
    end

    describe "#<<" do

      it "message with a newline are logged on info" do
        logger << "yo\n"

        stdout.string.must_equal colorize("       yo", opts[:color]) + "\n"
      end

      it "message with multiple newlines are separately logged on info" do
        logger << "yo\nheya\n"

        stdout.string.must_equal(
          colorize("       yo", opts[:color]) + "\n" +
          colorize("       heya", opts[:color]) + "\n"
        )
      end

      it "message with info, error, and banner lines will be preserved" do
        logger << [
          "-----> banner",
          "       info",
          ">>>>>> error",
          "vanilla"
        ].join("\n").concat("\n")

        stdout.string.must_equal(
          colorize("-----> banner", opts[:color]) + "\n" +
          colorize("       info", opts[:color]) + "\n" +
          colorize(">>>>>> error", opts[:color]) + "\n" +
          colorize("       vanilla", opts[:color]) + "\n"
        )
      end

      it "message with line that is not newline terminated will be buffered" do
        logger << [
          "-----> banner",
          "       info",
          "partial"
        ].join("\n")

        stdout.string.must_equal(
          colorize("-----> banner", opts[:color]) + "\n" +
          colorize("       info", opts[:color]) + "\n"
        )
      end

      it "logger with buffered data will flush on next message with newline" do
        logger << "partial"
        logger << "ly\nokay\n"

        stdout.string.must_equal(
          colorize("       partially", opts[:color]) + "\n" +
          colorize("       okay", opts[:color]) + "\n"
        )
      end

      it "logger that receives mixed first chunk will flush next message with newline" do
        logger << "partially\no"
        logger << "kay\n"

        stdout.string.must_equal(
          colorize("       partially", opts[:color]) + "\n" +
          colorize("       okay", opts[:color]) + "\n"
        )
      end

      it "logger chomps carriage return characters" do
        logger << [
          "-----> banner\r",
          "vanilla\r"
        ].join("\n").concat("\n")

        stdout.string.must_equal(
          colorize("-----> banner", opts[:color]) + "\n" +
          colorize("       vanilla", opts[:color]) + "\n"
        )
      end
    end
  end

  describe "opened IO logdev-based logger" do

    let(:logdev) { StringIO.new }

    before { opts[:logdev] = logdev }

    describe "for severity" do

      before { opts[:level] = Kitchen::Util.to_logger_level(:debug) }

      let(:ts) { "\\[[^\\]]+\\]" }

      it "logs to banner" do
        logger.banner("yo")

        logdev.string.must_match(/^I, #{ts}  INFO -- Kitchen: -----> yo$/)
      end

      it "logs to debug" do
        logger.debug("yo")

        logdev.string.must_match(/^D, #{ts} DEBUG -- Kitchen: yo$/)
      end

      it "logs to info" do
        logger.info("yo")

        logdev.string.must_match(/^I, #{ts}  INFO -- Kitchen: yo$/)
      end

      it "logs to error" do
        logger.error("yo")

        logdev.string.must_match(/^E, #{ts} ERROR -- Kitchen: yo$/)
      end

      it "logs to warn" do
        logger.warn("yo")

        logdev.string.must_match(/^W, #{ts}  WARN -- Kitchen: yo$/)
      end

      it "logs to fatal" do
        logger.fatal("yo")

        logdev.string.must_match(/^F, #{ts} FATAL -- Kitchen: yo$/)
      end

      it "logs to unknown" do
        logger.unknown("yo")

        logdev.string.must_match(/^A, #{ts}   ANY -- Kitchen: yo$/)
      end
    end
  end

  describe "file IO logdev-based logger" do

    let(:logfile) { Dir::Tmpname.make_tmpname(%w[kitchen .log], nil) }

    before do
      opts[:logdev] = logfile
      FakeFS.activate!
      FileUtils.mkdir_p("/tmp")
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    describe "for severity" do

      before { opts[:level] = Kitchen::Util.to_logger_level(:debug) }

      let(:ts) { "\\[[^\\]]+\\]" }

      it "logs to banner" do
        logger.banner("yo")

        IO.read(logfile).must_match(/^I, #{ts}  INFO -- Kitchen: -----> yo$/)
      end

      it "logs to debug" do
        logger.debug("yo")

        IO.read(logfile).must_match(/^D, #{ts} DEBUG -- Kitchen: yo$/)
      end

      it "logs to info" do
        logger.info("yo")

        IO.read(logfile).must_match(/^I, #{ts}  INFO -- Kitchen: yo$/)
      end

      it "logs to error" do
        logger.error("yo")

        IO.read(logfile).must_match(/^E, #{ts} ERROR -- Kitchen: yo$/)
      end

      it "logs to warn" do
        logger.warn("yo")

        IO.read(logfile).must_match(/^W, #{ts}  WARN -- Kitchen: yo$/)
      end

      it "logs to fatal" do
        logger.fatal("yo")

        IO.read(logfile).must_match(/^F, #{ts} FATAL -- Kitchen: yo$/)
      end

      it "logs to unknown" do
        logger.unknown("yo")

        IO.read(logfile).must_match(/^A, #{ts}   ANY -- Kitchen: yo$/)
      end
    end
  end
end
