# frozen_string_literal: true
#
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Kitchen
  # Common Dependency Injection wiring for ChefUtils-related modules
  module ChefUtilsWiring
    private

    def __config
      # this would need to be some kind of Chef::Config looking thing, which probably requires
      # a translation object from t-k config to Chef::Config layout if that ever becomes necessary.
      # this ISN'T the t-k config.
      {}
    end

    def __log
      @logger
    end

    def __transport_connection
      # this could be wired up to train at some point, but need to be careful because about local vs. remote
      # uses of helpers with test-kitchen, right now we're using it for local.
    end
  end
end
