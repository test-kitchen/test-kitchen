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
