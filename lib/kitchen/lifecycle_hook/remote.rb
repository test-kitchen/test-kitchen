require_relative "base"
require_relative "../errors"

module Kitchen
  class LifecycleHook
    class Remote < Base
      # Execute a specific remote command hook.
      #
      # @return [void]
      def run
        # Check if we're in a state that makes sense to even try.
        unless instance.last_action
          if hook[:skippable]
            # Just not even trying.
            return
          else
            raise UserError, "Cannot use remote lifecycle hooks during phases when the instance is not available"
          end
        end

        begin
          conn = instance.transport.connection(state_file.read)
          conn.execute(command)
        rescue Kitchen::Transport::SshFailed => e
          return if hook[:skippable] && e.message.match(/^SSH exited \(\d{1,3}\) for command: \[.+\]$/)

          raise
        end
      end

      private

      # return [String]
      def command
        hook.fetch(:remote)
      end
    end
  end
end
