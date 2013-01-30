# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

  # A target operating system environment in which convergence integration
  # will take place. This may represent a specific operating system, version,
  # and machine architecture.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Platform

    # @return [String] logical name of this platform
    attr_reader :name

    # @return [Array] Array of Chef run_list items
    attr_reader :run_list

    # @return [Hash] Hash of Chef node attributes
    attr_reader :attributes

    # Constructs a new platform.
    #
    # @param [Hash] options configuration for a new platform
    # @option options [String] :name logical name of this platform
    #   (**Required**)
    # @option options [Array<String>] :run_list Array of Chef run_list
    #   items
    # @option options [Hash] :attributes Hash of Chef node attributes
    def initialize(options = {})
      validate_options(options)

      @name = options[:name]
      @run_list = Array(options[:run_list])
      @attributes = options[:attributes] || Hash.new
    end

    private

    def validate_options(opts)
      [:name].each do |k|
        raise ClientError, "Platform#new requires option :#{k}" if opts[k].nil?
      end
    end
  end
end
