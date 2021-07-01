# Deprecated AS PER THE PR - https://github.com/test-kitchen/test-kitchen/pull/1730
require_relative "chef_infra"

module Kitchen
  module Provisioner
    # Chef Zero provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefZero < ChefInfra
    end
  end
end
