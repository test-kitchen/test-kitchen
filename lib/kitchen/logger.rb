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

require "fileutils"
require "logger"

module Kitchen

  # Logging implementation for Kitchen. By default the console/stdout output
  # will be displayed differently than the file log output. Therefor, this
  # class wraps multiple loggers that conform to the stdlib `Logger` class
  # behavior.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Logger

    include ::Logger::Severity

    # @return [IO] the log device
    attr_reader :logdev

    # @return [Boolean] whether logger is configured for
    #   overwriting
    attr_reader :log_overwrite

    # Constructs a new logger.
    #
    # @param options [Hash] configuration for a new logger
    # @option options [Symbol] :color color to use when when outputting
    #   messages
    # @option options [Integer] :level the logging severity threshold
    #   (default: `Kitchen::DEFAULT_LOG_LEVEL`)
    # @option options [Boolean] whether to overwrite the log
    #   when Test Kitchen runs. Only applies if the :logdev is a String.
    #   (default: `Kitchen::DEFAULT_LOG_OVERWRITE`)
    # @option options [String,IO] :logdev filepath String or IO object to be
    #   used for logging (default: `nil`)
    # @option options [String] :progname program name to include in log
    #   messages (default: `"Kitchen"`)
    # @option options [IO] :stdout a standard out IO object to use
    #   (default: `$stdout`)
    # @option options [Boolean] :colorize whether to colorize output
    #   when Test Kitchen runs.
    #   (default: `$stdout.tty?`)
    def initialize(options = {})
      @log_overwrite = if options[:log_overwrite].nil?
        default_log_overwrite
      else
        options[:log_overwrite]
      end

      @logdev = logdev_logger(options[:logdev], log_overwrite) if options[:logdev]

      populate_loggers(options)

      # These setters cannot be called until @loggers are populated because
      # they are delegated
      self.progname = options[:progname] || "Kitchen"
      self.level = options[:level] || default_log_level
    end

    # Pulled out for Rubocop complexity issues
    #
    # @api private
    def populate_loggers(options)
      @loggers = []
      @loggers << logdev unless logdev.nil?
      @loggers << stdout_logger(options[:stdout], options[:color], options[:colorize]) if
        options[:stdout]
      @loggers << stdout_logger($stdout, options[:color], options[:colorize]) if
        @loggers.empty?
    end
    private :populate_loggers

    class << self

      private

      # @api private
      # @!macro delegate_to_first_logger
      #   @method $1()
      def delegate_to_first_logger(meth)
        define_method(meth) { |*args| @loggers.first.public_send(meth, *args) }
      end

      # @api private
      # @!macro delegate_to_all_loggers
      #   @method $1()
      def delegate_to_all_loggers(meth)
        define_method(meth) do |*args|
          result = nil
          @loggers.each { |l| result = l.public_send(meth, *args) }
          result
        end
      end
    end

    # @return [Integer] the logging severity threshold
    # @see http://is.gd/Okuy5p
    delegate_to_first_logger :level

    # Sets the logging severity threshold.
    #
    # @param level [Integer] the logging severity threshold
    # @see http://is.gd/H1VBFH
    delegate_to_all_loggers :level=

    # @return [String] program name to include in log messages
    # @see http://is.gd/5uHGK0
    delegate_to_first_logger :progname

    # Sets the program name to include in log messages.
    #
    # @param progname [String] the program name to include in log messages
    # @see http://is.gd/f2U5Xj
    delegate_to_all_loggers :progname=

    # @return [String] the date format being used
    # @see http://is.gd/btmFWJ
    delegate_to_first_logger :datetime_format

    # Sets the date format being used.
    #
    # @param format [String] the date format
    # @see http://is.gd/M36ml8
    delegate_to_all_loggers :datetime_format=

    # Log a message if the given severity is high enough.
    #
    # @see http://is.gd/5opBW0
    delegate_to_all_loggers :add

    # Dump one or more messages to info.
    #
    # @param message [#to_s] the message to log
    # @see http://is.gd/BCp5KV
    delegate_to_all_loggers :<<

    # Log a message with severity of banner (high level).
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/pYUCYU
    delegate_to_all_loggers :banner

    # Log a message with severity of debug.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/Re97Zp
    delegate_to_all_loggers :debug

    # @return [true,false] whether or not the current severity level
    #   allows for the printing of debug messages
    # @see http://is.gd/Iq08xB
    delegate_to_first_logger :debug?

    # Log a message with severity of info.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/pYUCYU
    delegate_to_all_loggers :info

    # @return [true,false] whether or not the current severity level
    #   allows for the printing of info messages
    # @see http://is.gd/lBtJkT
    delegate_to_first_logger :info?

    # Log a message with severity of error.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/mLwYMl
    delegate_to_all_loggers :error

    # @return [true,false] whether or not the current severity level
    #   allows for the printing of error messages
    # @see http://is.gd/QY19JL
    delegate_to_first_logger :error?

    # Log a message with severity of warn.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/PX9AIS
    delegate_to_all_loggers :warn

    # @return [true,false] whether or not the current severity level
    #   allows for the printing of warn messages
    # @see http://is.gd/Gdr4lD
    delegate_to_first_logger :warn?

    # Log a message with severity of fatal.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/5ElFPK
    delegate_to_all_loggers :fatal

    # @return [true,false] whether or not the current severity level
    #   allows for the printing of fatal messages
    # @see http://is.gd/7PgwRl
    delegate_to_first_logger :fatal?

    # Log a message with severity of unknown.
    #
    # @param message_or_progname [#to_s] the message to log. In the block
    #   form, this is the progname to use in the log message.
    # @yield evaluates to the message to log. This is not evaluated unless the
    #   logger's level is sufficient to log the message. This allows you to
    #   create potentially expensive logging messages that are only called when
    #   the logger is configured to show them.
    # @return [nil,true] when the given severity is not high enough (for this
    #   particular logger), log no message, and return true
    # @see http://is.gd/Y4hqpf
    delegate_to_all_loggers :unknown

    # Close the logging devices.
    #
    # @see http://is.gd/b13cVn
    delegate_to_all_loggers :close

    private

    # @return [Integer] the default logger level
    # @api private
    def default_log_level
      Util.to_logger_level(Kitchen::DEFAULT_LOG_LEVEL)
    end

    # @return [Boolean] whether to overwrite logs by default
    # @api private
    def default_log_overwrite
      Kitchen::DEFAULT_LOG_OVERWRITE
    end

    # Construct a new standard out logger.
    #
    # @param stdout [IO] the IO object that represents stdout (or similar)
    # @param color [Symbol] color to use when outputing messages
    # @param colorize [Boolean] whether to enable color
    # @return [StdoutLogger] a new logger
    # @api private
    def stdout_logger(stdout, color, colorize)
      logger = StdoutLogger.new(stdout)
      if colorize
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          Color.colorize("#{msg}", color).concat("\n")
        end
      else
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          msg.concat("\n")
        end
      end
      logger
    end

    # Construct a new logdev logger.
    #
    # @param filepath_or_logdev [String,IO] a filepath String or IO object
    # @param log_overwrite [Boolean] apply log overwriting
    #   if filepath_or_logdev is a file path
    # @return [LogdevLogger] a new logger
    # @api private
    def logdev_logger(filepath_or_logdev, log_overwrite)
      LogdevLogger.new(resolve_logdev(filepath_or_logdev, log_overwrite))
    end

    # Return an IO object from a filepath String or the IO object itself.
    #
    # @param filepath_or_logdev [String,IO] a filepath String or IO object
    # @param log_overwrite [Boolean] apply log overwriting
    #   if filepath_or_logdev is a file path
    # @return [IO] an IO object
    # @api private
    def resolve_logdev(filepath_or_logdev, log_overwrite)
      if filepath_or_logdev.is_a? String
        mode = log_overwrite ? "wb" : "ab"
        FileUtils.mkdir_p(File.dirname(filepath_or_logdev))
        file = File.open(File.expand_path(filepath_or_logdev), mode)
        file.sync = true
        file
      else
        filepath_or_logdev
      end
    end

    # Internal class which adds a #banner method call that displays the
    # message with a callout arrow.
    class LogdevLogger < ::Logger

      alias_method :super_info, :info

      # Dump one or more messages to info.
      #
      # @param msg [String] a message
      def <<(msg)
        @buffer ||= ""
        @buffer += msg
        while i = @buffer.index("\n")
          format_line(@buffer[0, i].chomp)
          @buffer[0, i + 1] = ""
        end
      end

      # Log a banner message.
      #
      # @param msg [String] a message
      def banner(msg = nil, &block)
        super_info("-----> #{msg}", &block)
      end

      private

      # Reformat a line if it already contains log formatting.
      #
      # @param line [String] a message line
      # @api private
      def format_line(line)
        case line
        when %r{^-----> } then banner(line.gsub(%r{^[ >-]{6} }, ""))
        when %r{^>>>>>> } then error(line.gsub(%r{^[ >-]{6} }, ""))
        when %r{^       } then info(line.gsub(%r{^[ >-]{6} }, ""))
        else info(line)
        end
      end
    end

    # Internal class which reformats logging methods for display as console
    # output.
    class StdoutLogger < LogdevLogger

      # Log a debug message
      #
      # @param msg [String] a message
      def debug(msg = nil, &block)
        super("D      #{msg}", &block)
      end

      # Log an info message
      #
      # @param msg [String] a message
      def info(msg = nil, &block)
        super("       #{msg}", &block)
      end

      # Log a warn message
      #
      # @param msg [String] a message
      def warn(msg = nil, &block)
        super("$$$$$$ #{msg}", &block)
      end

      # Log an error message
      #
      # @param msg [String] a message
      def error(msg = nil, &block)
        super(">>>>>> #{msg}", &block)
      end

      # Log a fatal message
      #
      # @param msg [String] a message
      def fatal(msg = nil, &block)
        super("!!!!!! #{msg}", &block)
      end

      # Log an unknown message
      #
      # @param msg [String] a message
      def unknown(msg = nil, &block)
        super("?????? #{msg}", &block)
      end
    end
  end
end
