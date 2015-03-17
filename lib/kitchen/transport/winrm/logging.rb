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

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # Mixin to use an optionally provided logger for logging.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      module Logging

        # Logs a message on the logger at the debug level, if a logger is
        # present.
        #
        # @param msg [String] a message to log
        # @yield evaluates and uses return value as message to log. If msg
        #   parameter is set, it will take precedence over the block.
        def debug(msg = nil, &block)
          return if logger.nil? || !logger.debug?
          logger.debug("[#{log_subject}] " << (msg || block.call))
        end

        # The subject for log messages.
        #
        # @return [String] log subject
        def log_subject
          @log_subject ||= self.class.to_s.split("::").last
        end
      end
    end
  end
end
