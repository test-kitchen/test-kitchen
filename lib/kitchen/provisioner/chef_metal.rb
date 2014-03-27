# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Chef Metal provisioner.
    # To be fair, metal doesn't actually use a provisioner at all; what this is is
    # a window to the test configuration so that the Chef Metal driver can get to
    # the parameters it needs
    #
    # @author Douglas Triggs <doug@getchef.com>
    class ChefMetal < Base

      attr_reader :config

    end
  end
end
