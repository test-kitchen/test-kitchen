require 'chef_metal/action_handler'

module Kitchen
  class KitchenActionHandler < ChefMetal::ActionHandler
    def action_performed(description)
      Array(description).each do |line|
        puts "ACTION! #{line}"
      end
    end
  end
end
