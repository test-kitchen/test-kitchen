module Kitchen
  module Transport
    # Base class that defines the Transport interface
    class Base
      attr_accessor :config
      attr_accessor :logger
      attr_accessor :connection

      def initialize(config, state, logger)
        # Save the config from the driver
        @config = config
        @logger = logger
      end

      def env_cmd(cmd)
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def run_remote(command, connection)
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def transfer_path(locals, remote, connection)
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def wait_for_connection(hostname, username = nil, options = {})
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def login_command
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def disconnect
        raise ClientError, "#{self.class}#create must be implemented"
      end
    end
  end
end
