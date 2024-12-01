#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
# Copyright (C) 2018, Chef Software
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../spec_helper"

require "logger"

require "kitchen/plugin"

module Kitchen
  module RandoPlugin
    require "kitchen/configurable"

    class Base
      include Configurable

      def initialize(config = {})
        init_config(config)
      end

      def verify_dependencies; end
    end

    class Coolbeans < Base
    end

    class ItDepends < Base
      attr_reader :verify_call_count

      def initialize(config = {})
        @verify_call_count = 0
        super
      end

      def verify_dependencies
        @verify_call_count += 1
      end
    end

    class UnstableDepends < Base
      def verify_dependencies
        raise UserError, "Oh noes, you don't have software!"
      end
    end
  end
end

describe ".load" do
  before do
  end

  describe "for a plugin type" do
    it "returns a plugin" do
      Kitchen::Plugin.stubs(:require).returns(true)
      plugin = Kitchen::Plugin.load(Kitchen::RandoPlugin, "coolbeans", {})

      _(plugin).must_be_kind_of Kitchen::RandoPlugin::Coolbeans
    end

    it "returns a plugin initialized with its config" do
      Kitchen::Plugin.stubs(:require).returns(true)
      plugin = Kitchen::Plugin.load(Kitchen::RandoPlugin, "coolbeans", jelly: "beans")

      _(plugin[:jelly]).must_equal "beans"
    end

    it "calls #verify_dependencies on the plugin object" do
      Kitchen::Plugin.stubs(:require).returns(true)
      driver = Kitchen::Plugin.load(Kitchen::RandoPlugin, "it_depends", {})

      _(driver.verify_call_count).must_equal 1
    end

    it "calls #verify_dependencies once per plugin require" do
      Kitchen::Plugin.stubs(:require).returns(true, false)
      plugin1 = Kitchen::Plugin.load(Kitchen::RandoPlugin, "it_depends", {})
      _(plugin1.verify_call_count).must_equal 1
      plugin2 = Kitchen::Plugin.load(Kitchen::RandoPlugin, "it_depends", {})

      _(plugin2.verify_call_count).must_equal 0
    end

    it "raises ClientError if the plugin could not be required" do
      Kitchen::Plugin.stubs(:require).raises(LoadError)

      error = assert_raises(Kitchen::ClientError) { Kitchen::Plugin.load(Kitchen::RandoPlugin, "coolbeans", {}) }
      _(error.message).must_include "Could not load the 'coolbeans' rando_plugin from the load path."
      _(error.message).must_include "Did you mean"
    end

    it "raises ClientError if plugin is found on load path but require still fails" do
      Kitchen::Plugin.stubs(:require).raises(LoadError, "Some other problem.")
      Kitchen::Plugin.stubs(:plugins_available).returns(%w{coolbeans})

      error = assert_raises(Kitchen::ClientError) { Kitchen::Plugin.load(Kitchen::RandoPlugin, "coolbeans", {}) }
      _(error.message).must_include "Could not load the 'coolbeans' rando_plugin from the load path."
      _(error.message).must_include "Some other problem."
      _(error.message).wont_include "Did you mean"
    end

    it "raises ClientError if the plugin's class constant could not be found" do
      Kitchen::Plugin.stubs(:require).returns(true) # pretend require worked

      error = assert_raises(Kitchen::ClientError) { Kitchen::Plugin.load(Kitchen::RandoPlugin, "isnt_the_actual_class_name", {}) }
      _(error.message).must_include "uninitialized constant Kitchen::RandoPlugin::IsntTheActualClassName"
    end

    it "raises UserError if #verify_dependencies fails" do
      Kitchen::Plugin.stubs(:require).returns(true)
      _ { Kitchen::Plugin.load(Kitchen::RandoPlugin, "unstable_depends", {}) }
        .must_raise Kitchen::UserError
    end
  end
end
