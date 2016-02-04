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

    # @return [String] operating system type hint (default: `"unix"`)
    attr_reader :os_type

    # @return [String] shell command flavor hint (default: `"bourne"`)
    attr_reader :shell_type

    # Constructs a new platform.
    #
    # @param [Hash] options configuration for a new platform
    # @option options [String] :name logical name of this platform
    #   (**Required**)
    def initialize(options = {})
      @name = options.fetch(:name) do
        raise ClientError, "Platform#new requires option :name"
      end
      @os_type = options.fetch(:os_type) do
        windows?(options) ? "windows" : "unix"
      end
      @shell_type = options.fetch(:shell_type) do
        windows?(options) ? "powershell" : "bourne"
      end
    end

    def windows?(options)
      @name.downcase =~ /^win/ || (
        !options[:transport].nil? && options[:transport][:name] == "winrm"
      )
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      { :os_type => os_type, :shell_type => shell_type }
    end
  end
end
