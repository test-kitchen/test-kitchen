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

require 'kitchen/util'

module Kitchen

  # Combines and compiles diagnostic information about a Test Kitchen
  # configuration suitable for support and troubleshooting.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Diagnostic

    def initialize(options = {})
      @loader = options.fetch(:loader, nil)
      @instances = options.fetch(:instances, [])
      @result = Hash.new
    end

    def read
      prepare_common
      prepare_loader
      prepare_instances

      Util.stringified_hash(result)
    end

    private

    attr_reader :result, :loader, :instances

    def prepare_common
      result[:timestamp] = Time.now.gmtime
      result[:kitchen_version] = Kitchen::VERSION
    end

    def prepare_loader
      if error_hash?(loader)
        result[:loader] = loader
      else
        result[:loader] = loader.diagnose if loader
      end
    end

    def prepare_instances
      result[:instances] = Hash.new
      if error_hash?(instances)
        result[:instances][:error] = instances[:error]
      else
        Array(instances).each { |i| result[:instances][i.name] = i.diagnose }
      end
    end

    def error_hash?(obj)
      obj.is_a?(Hash) && obj.key?(:error)
    end
  end
end
