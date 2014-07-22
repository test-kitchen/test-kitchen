require 'kitchen/transport/base'
require 'kitchen/transport/ssh'

module Kitchen
  module Transport

    module Type
      # Currenly supported transports
      SSH = "SSH".freeze
      WinRM = "WinRM".freeze
    end

    def self.instantiate(type, state, driver)
      transport_class = Kernel.const_get("Kitchen::Transport::#{type}")
      # TODO: Catch `NameError: uninitialized constant Kitchen::Transport::Unknown`

      transport = transport_class.new(state, driver)

      if block_given?
        yield transport
        transport.disconnect
      else
        transport
      end
    end

    def self.transfer_path
      raise ClientError, "#{self.class}#create must be implemented"
    end
  end
end
