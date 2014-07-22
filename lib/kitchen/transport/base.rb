module Kitchen
  module Transport
    # Base class that defines the Transport interface
    class Base
      attr_accessor :driver
      attr_accessor :connection

      def initialize(state, driver)
        # Save the config from the driver
        @driver = driver
        @connection = nil
      end

      def run_remote(command, connection)
        raise ClientError, "#{self.class}#run_remote must be implemented"
      end

      def transfer_path(locals, remote, connection)
        raise ClientError, "#{self.class}#transfer_path must be implemented"
      end

      def wait_for_connection(hostname, username = nil, options = {})
        raise ClientError, "#{self.class}#wait_for_connection must be implemented"
      end

      def login_command
        raise ClientError, "#{self.class}#login_command must be implemented"
      end

      def disconnect
        raise ClientError, "#{self.class}#disconnect must be implemented"
      end
    end
  end
end
