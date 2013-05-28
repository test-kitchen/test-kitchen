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

module Kitchen

  # Value object to track a shell command that will be passed to Kernel.exec
  # for execution.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class LoginCommand

    attr_reader :cmd_array, :options

    def initialize(cmd_array, options = {})
      @cmd_array = cmd_array
      @options = options
    end
  end
end
