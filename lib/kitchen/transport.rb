require 'kitchen/transport/base'
require 'kitchen/transport/ssh'

module Kitchen
  module Transport
    def self.instantiate(config, state, logger)
      transport_class = Kernel.const_get("Kitchen::Transport::#{config[:transport]}")
      # TODO: Catch `NameError: uninitialized constant Kitchen::Transport::Unknown`

      transport = transport_class.new(config, state, logger)

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
