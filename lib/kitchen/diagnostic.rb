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

require "kitchen/util"
require "kitchen/version"

module Kitchen
  # Combines and compiles diagnostic information about a Test Kitchen
  # configuration suitable for support and troubleshooting.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Diagnostic
    # Constructs a new Diagnostic object with an optional loader and optional
    # instances array.
    #
    # @param options [Hash] optional configuration
    # @option options [#diagnose,Hash] :loader a loader instance that responds
    #   to `#diagnose` or an error Hash
    # @option options [Array<#diagnose>,Hash] :instances an Array of instances
    #   that respond to `#diagnose` or an error Hash
    # @option options [true,false] :plugins whether or not plugins should be
    #   returned
    def initialize(options = {})
      @loader = options.fetch(:loader, nil)
      @instances = options.fetch(:instances, [])
      @plugins = options.fetch(:plugins, false)
      @result = {}
    end

    # Returns a Hash with stringified keys containing diagnostic information.
    #
    # @return [Hash] a configuration Hash
    def read
      prepare_common
      prepare_plugins
      prepare_loader
      prepare_instances

      Util.stringified_hash(result)
    end

    private

    # @return [Hash] a result hash
    # @api private
    attr_reader :result

    # @return [#diagnose,Hash] a loader instance that responds to `#diagnose`
    #   or an error Hash
    # @api private
    attr_reader :loader

    # @return [Array<#diagnose>,Hash] an Array of instances that respond to
    #   `#diagnose` or an error Hash
    # @api private
    attr_reader :instances

    # Adds common information to the result Hash.
    #
    # @api private
    def prepare_common
      result[:timestamp] = Time.now.gmtime.to_s
      result[:kitchen_version] = Kitchen::VERSION
    end

    # Adds loader information to the result Hash.
    #
    # @api private
    def prepare_loader
      if error_hash?(loader)
        result[:loader] = loader
      else
        result[:loader] = loader.diagnose if loader
      end
    end

    # Adds plugin information to the result Hash.
    #
    # @api private
    def prepare_plugins
      return unless @plugins

      if error_hash?(instances)
        result[:plugins] = { error: instances[:error] }
      elsif instances.empty?
        result[:plugins] = {}
      else
        plugins = {
          driver: [], provisioner: [], transport: [], verifier: []
        }
        instances.map(&:diagnose_plugins).each do |plugin_hash|
          plugin_hash.each { |type, plugin| plugins[type] << plugin }
        end
        plugins.each do |type, list|
          plugins[type] =
            Hash[list.uniq.map { |hash| [hash.delete(:name), hash] }]
        end
        result[:plugins] = plugins
      end
    end

    # Adds instance information to the result Hash.
    #
    # @api private
    def prepare_instances
      result[:instances] = {}
      if error_hash?(instances)
        result[:instances][:error] = instances[:error]
      else
        Array(instances).each { |i| result[:instances][i.name] = i.diagnose }
      end
    end

    # Determins whether or not the object is an error hash. An error hash is
    # defined as a Hash containing an `:error` key.
    #
    # @param obj [Object] an object
    # @return [true,false] whether or not the object is an error hash
    # @api private
    def error_hash?(obj)
      obj.is_a?(Hash) && obj.key?(:error)
    end
  end
end
