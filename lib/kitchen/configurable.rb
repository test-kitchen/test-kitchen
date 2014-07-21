# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require "thor/util"

require "kitchen/lazy_hash"

module Kitchen

  # A mixin for providing configuration-related behavior such as default
  # config (static, computed, inherited), required config, local path
  # expansion, etc.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Configurable

    def self.included(base)
      base.extend(ClassMethods)
    end

    # @return [Kitchen::Instance] the associated instance
    attr_reader :instance

    # A lifecycle method that should be invoked when the object is about ready
    # to be used. A reference to an Instance is required as configuration
    # dependant data may be access through an Instance. This also acts as a
    # hook point where the object may wish to perform other last minute
    # checks, validations, or configuration expansions.
    #
    # @param instance [Instance] an associated instance
    # @return [self] itself, for use in chaining
    # @raise [ClientError] if instance parameter is nil
    def finalize_config!(instance)
      if instance.nil?
        raise ClientError, "Instance must be provided to #{self}"
      end

      @instance = instance
      expand_paths!
      validate_config!

      self
    end

    # Provides hash-like access to configuration keys.
    #
    # @param attr [Object] configuration key
    # @return [Object] value at configuration key
    def [](attr)
      config[attr]
    end

    # Find an appropriate path to a file or directory, based on graceful
    # fallback rules or returns nil if path cannot be determined.
    #
    # Given an instance with suite named `"server"`, a `test_base_path` of
    # `"/a/b"`, and a path segement of `"roles"` then following will be tried
    # in order (first match that exists wins):
    #
    # 1. /a/b/server/roles
    # 2. /a/b/roles
    # 3. $PWD/roles
    #
    # @param path [String] the base path segment to search for
    # @param opts [Hash] options
    # @option opts [Symbol] :type either `:file` or `:directory` (default)
    # @option opts [Symbol] :base_path a custom base path to search under,
    #   default uses value from `config[:test_base_path]`
    # @return [String] path to the existing file or directory, or nil if file
    #   or directory was not found
    # @raise [UserError] if `config[:test_base_path]` is used and is not set
    def calculate_path(path, opts = {})
      type = opts.fetch(:type, :directory)
      base = opts.fetch(:base_path) do
        config.fetch(:test_base_path) do |key|
          raise UserError, "#{key} is not found in #{self}"
        end
      end

      [
        File.join(base, instance.suite.name, path),
        File.join(base, path),
        File.join(Dir.pwd, path)
      ].find do |candidate|
        type == :directory ? File.directory?(candidate) : File.file?(candidate)
      end
    end

    # Returns an array of configuration keys.
    #
    # @return [Array] array of configuration keys
    def config_keys
      config.keys
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      result = Hash.new
      config_keys.sort.each { |k| result[k] = config[k] }
      result
    end

    private

    # @return [LzayHash] a configuration hash
    # @api private
    attr_reader :config

    # Initializes an internal configuration hash. The hash may contain
    # callable blocks as values that are meant to be called lazily. This
    # method is intended to be included in an object's .initialize method.
    #
    # @param config [Hash] initial provided configuration
    # @api private
    def init_config(config)
      @config = LazyHash.new(config, self)
      self.class.defaults.each do |attr, value|
        @config[attr] = value unless @config.key?(attr)
      end
    end

    # Expands file paths for certain configuration values. A configuration
    # value is marked for file expansion with a expand_path_for declaration
    # in the included class.
    #
    # @api private
    def expand_paths!
      root_path = config[:kitchen_root] || Dir.pwd
      expanded_paths = LazyHash.new(self.class.expanded_paths, self).to_hash

      expanded_paths.each do |key, should_expand|
        next if !should_expand || config[key].nil?

        config[key] = File.expand_path(config[key], root_path)
      end
    end

    # Runs all validations set up for the included class. Each validation is
    # for a specific configuration attribute and has an associated callable
    # block. Each validation block is called with the attribute, its value,
    # and the included object for context.
    #
    # @api private
    def validate_config!
      self.class.validations.each do |attr, block|
        block.call(attr, config[attr], self)
      end
    end

    # Class methods which will be mixed in on inclusion of Configurable module.
    module ClassMethods

      # Sets a sane default value for a configuration attribute. These values
      # can be overridden by provided configuration or in a subclass with
      # another default_config declaration.
      #
      # @example a nil default value
      #
      #   default_config :i_am_nil
      #
      # @example a primitive default value
      #
      #   default_config :use_sudo, true
      #
      # @example a block to compute a default value
      #
      #   default_config :box_name do |subject|
      #     subject.instance.platform.name
      #   end
      #
      # @param attr [String] configuration attribute name
      # @param value [Object, nil] static default value for attribute
      # @yieldparam object [Object] a reference to the instantiated object
      # @yieldreturn [Object, nil] dynamically computed value for the attribute
      def default_config(attr, value = nil, &block)
        defaults[attr] = block_given? ? block : value
      end

      # Ensures that an attribute which is a path will be fully expanded at
      # the right time. This helps make the configuration unambiguous and much
      # easier to debug and diagnose.
      #
      # Note that the file path expansion is only intended for paths on the
      # local workstation invking the Test Kitchen code.
      #
      # @example the default usage
      #
      #   expand_path_for :data_path
      #
      # @example disabling path expansion with a falsey value
      #
      #   expand_path_for :relative_path, false
      #
      # @example using a block to determine whether or not to expand
      #
      #   expand_path_for :relative_or_not_path do |subject|
      #     subject.instance.name =~ /default/
      #   end
      #
      # @param attr [String] configuration attribute name
      # @param value [Object, nil] whether or not to exand the file path
      # @yieldparam object [Object] a reference to the instantiated object
      # @yieldreturn [Object, nil] dynamically compute whether or not to
      #   perform the file expansion
      def expand_path_for(attr, value = true, &block)
        expanded_paths[attr] = block_given? ? block : value
      end

      # Ensures that an attribute must have a non-nil, non-empty String value.
      # The default behavior will be to raise a user error and thereby halting
      # further configuration processing. Good use cases for require_config
      # might be cloud provider credential keys and other similar data.
      #
      # @example a value that must not be nil or an empty String
      #
      #   required_config :cloud_api_token
      #
      # @example using a block to use custom validation logic
      #
      #   required_config :email do |attr, value, subject|
      #     raise UserError, "Must be an email address" unless value =~ /@/
      #   end
      #
      # @param attr [String] configuration attribute name
      # @yieldparam attr [Symbol] the attribute name
      # @yieldparam value [Object] the current value of the attribute
      # @yieldparam object [Object] a reference to the instantiated object
      def required_config(attr, &block)
        if !block_given?
          klass = self
          block = lambda do |_, value, thing|
            if value.nil? || value.to_s.empty?
              attribute = "#{klass}#{thing.instance.to_str}#config[:#{attr}]"
              raise UserError, "#{attribute} cannot be blank"
            end
          end
        end
        validations[attr] = block
      end

      # @return [Hash] a hash of attribute keys and default values which has
      #   been merged with any superclass defaults
      # @api private
      def defaults
        @defaults ||= Hash.new.merge(super_defaults)
      end

      # @return [Hash] a hash of defaults from the included class' superclass
      #   if defined in the superclass, or an empty hash otherwise
      # @api private
      def super_defaults
        if superclass.respond_to?(:defaults)
          superclass.defaults
        else
          Hash.new
        end
      end

      # @return [Hash] a hash of attribute keys and truthy/falsey values to
      #   determine if said attribute needs to be fully file path expanded,
      #   which has been merged with any superclass expanded paths
      # @api private
      def expanded_paths
        @expanded_paths ||= Hash.new.merge(super_expanded_paths)
      end

      # @return [Hash] a hash of expanded paths from the included class'
      #   superclass if defined in the superclass, or an empty hash otherwise
      # @api private
      def super_expanded_paths
        if superclass.respond_to?(:expanded_paths)
          superclass.expanded_paths
        else
          Hash.new
        end
      end

      # @return [Hash] a hash of attribute keys and valudation callable blocks
      #   which has been merged with any superclass valudations
      # @api private
      def validations
        @validations ||= Hash.new.merge(super_validations)
      end

      # @return [Hash] a hash of validations from the included class'
      #   superclass if defined in the superclass, or an empty hash otherwise
      # @api private
      def super_validations
        if superclass.respond_to?(:validations)
          superclass.validations
        else
          Hash.new
        end
      end
    end
  end
end
