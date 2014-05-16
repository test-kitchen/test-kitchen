require 'chef_metal/machine_spec'

module Kitchen
  class KitchenMachineSpec < ChefMetal::MachineSpec
    def initialize(name, suite, platform, state_file)
      @state = state_file.read
      @state[:node] ||= { 'name' => name }
      super(@state[:node])
      @suite = suite
      @platform = platform
      @state_file = state_file
    end

    attr_reader :suite
    attr_reader :platform
    attr_reader :state
    attr_reader :state_file

    def id
      name
    end

    def save(action_handler)
      @state[:node] = node
      state_file.write(@state)
    end
  end
end
