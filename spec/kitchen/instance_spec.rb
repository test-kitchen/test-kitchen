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

require_relative '../spec_helper'
require 'logger'
require 'stringio'

require 'kitchen/logging'
require 'kitchen/instance'
require 'kitchen/driver'
require 'kitchen/driver/dummy'
require 'kitchen/platform'
require 'kitchen/suite'

describe Kitchen::Instance do

  let(:driver)    { Kitchen::Driver::Dummy.new({}) }
  let(:logger_io) { StringIO.new }
  let(:logger)    { ::Logger.new(logger_io) }
  let(:instance)  { Kitchen::Instance.new(opts) }

  let(:opts) do
    { :suite => suite, :platform => platform,
      :driver => driver, :logger => logger }
  end

  def suite(name = "suite")
    @suite ||= Kitchen::Suite.new({ :name => name })
  end

  def platform(name = "platform")
    @platform ||= Kitchen::Platform.new({ :name => name })
  end

  describe ".name_for" do

    it "combines the suite and platform names with a dash" do
      Kitchen::Instance.name_for(suite("suite"), platform("platform")).
        must_equal "suite-platform"
    end

    it "squashes periods in suite name" do
      Kitchen::Instance.name_for(suite("suite.ness"), platform("platform")).
        must_equal "suiteness-platform"
    end

    it "squashes periods in platform name" do
      Kitchen::Instance.name_for(suite("suite"), platform("platform.s")).
        must_equal "suite-platforms"
    end

    it "squashes periods in suite and platform names" do
      Kitchen::Instance.name_for(suite("s.s"), platform("p.p")).
        must_equal "ss-pp"
    end

    it "transforms underscores to dashes in suite name" do
      Kitchen::Instance.name_for(suite("suite_ness"), platform("platform")).
        must_equal "suite-ness-platform"
    end

    it "transforms underscores to dashes in platform name" do
      Kitchen::Instance.name_for(suite("suite"), platform("platform_s")).
        must_equal "suite-platform-s"
    end

    it "transforms underscores to dashes in suite and platform names" do
      Kitchen::Instance.name_for(suite("_s__s_"), platform("pp_")).
        must_equal "-s--s--pp-"
    end
  end

  describe "#suite" do

    it "returns its suite" do
      instance.suite.must_equal suite
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:suite)
      proc { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  describe "#platform" do

    it "returns its platform" do
      instance.platform.must_equal platform
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:platform)
      proc { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  describe "#driver" do

    it "returns its driver" do
      instance.driver.must_equal driver
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:driver)
      proc { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  describe "#logger" do

    it "returns its logger" do
      instance.logger.must_equal logger
    end

    it "uses Kitchen.logger by default" do
      opts.delete(:logger)
      instance.logger.must_equal Kitchen.logger
    end

    it "invokes #call yielding the instance name if logger is a Proc" do
      opts[:logger] = lambda { |name| "i'm a logger for #{name}" }
      instance.logger.must_equal "i'm a logger for suite-platform"
    end
  end

  it "#name returns it name" do
    instance.name.must_equal "suite-platform"
  end

  it "#to_str returns a string representation with its name" do
    instance.to_str.must_equal "<suite-platform>"
  end

  describe Kitchen::Instance::FSM do

    let(:fsm) { Kitchen::Instance::FSM }

    describe ".actions" do

      it "passing nils returns destroy" do
        fsm.actions(nil, nil).must_equal [:destroy]
      end

      it "accepts a string for desired argument" do
        fsm.actions(nil, "create").must_equal [:create]
      end

      it "accepts a symbol for desired argument" do
        fsm.actions(nil, :create).must_equal [:create]
      end

      it "starting from no state to create returns create" do
        fsm.actions(nil, :create).must_equal [:create]
      end

      it "starting from :create to create returns create" do
        fsm.actions(:create, :create).must_equal [:create]
      end

      it "starting from no state to converge returns create, converge" do
        fsm.actions(nil, :converge).must_equal [:create, :converge]
      end

      it "starting from create to converge returns converge" do
        fsm.actions(:create, :converge).must_equal [:converge]
      end

      it "starting from converge to converge returns converge" do
        fsm.actions(:converge, :converge).must_equal [:converge]
      end

      it "starting from no state to setup returns create, converge, setup" do
        fsm.actions(nil, :setup).must_equal [:create, :converge, :setup]
      end

      it "starting from create to setup returns converge, setup" do
        fsm.actions(:create, :setup).must_equal [:converge, :setup]
      end

      it "starting from converge to setup returns setup" do
        fsm.actions(:converge, :setup).must_equal [:setup]
      end

      it "starting from setup to setup return setup" do
        fsm.actions(:setup, :setup).must_equal [:setup]
      end

      it "starting from no state to verify returns create, converge, setup, verify" do
        fsm.actions(nil, :verify).must_equal [:create, :converge, :setup, :verify]
      end

      it "starting from create to verify returns converge, setup, verify" do
        fsm.actions(:create, :verify).must_equal [:converge, :setup, :verify]
      end

      it "starting from converge to verify returns setup, verify" do
        fsm.actions(:converge, :verify).must_equal [:setup, :verify]
      end

      it "starting from setup to verify returns verify" do
        fsm.actions(:setup, :verify).must_equal [:verify]
      end

      it "starting from verify to verify returns verify" do
        fsm.actions(:verify, :verify).must_equal [:verify]
      end

      [:verify, :setup, :converge].each do |s|
        it "starting from #{s} to create returns create" do
          fsm.actions(s, :create).must_equal [:create]
        end
      end

      [:verify, :setup].each do |s|
        it "starting from #{s} to converge returns converge" do
          fsm.actions(s, :converge).must_equal [:converge]
        end
      end

      it "starting from verify to setup returns setup" do
        fsm.actions(:verify, :setup).must_equal [:setup]
      end
    end
  end
end
