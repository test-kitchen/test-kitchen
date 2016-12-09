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
  # Mixin module that delegates logging methods to a local `#logger`.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Logging
    class << self
      private

      # @api private
      # @!macro logger_method
      #   @method $1($2)
      #   Log a message with severity of $1
      #   @param message_or_progname [#to_s] the message to log. In the block
      #     form, this is the progname to use in the log message.
      #   @yield evaluates to the message to log. This is not evaluated unless
      #     the logger's level is sufficient to log the message. This allows
      #     you to create potentially expensive logging messages that are
      #     only called when the logger is configured to show them.
      #   @return [nil,true] when the given severity is not high enough (for
      #     this particular logger), log no message, and return true
      def logger_method(meth)
        define_method(meth) do |*args|
          logger.public_send(meth, *args)
        end
      end
    end

    logger_method :banner
    logger_method :debug
    logger_method :info
    logger_method :warn
    logger_method :error
    logger_method :fatal
  end
end
