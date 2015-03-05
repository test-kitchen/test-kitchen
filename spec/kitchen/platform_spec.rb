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

require_relative "../spec_helper"

require "kitchen/errors"
require "kitchen/platform"

describe Kitchen::Platform do

  let(:opts) do; { :name => "plata" }; end
  let(:klass) { Kitchen::Platform }

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { klass.new(opts) }.must_raise Kitchen::ClientError
  end

  it "#os_type returns value passed into constructor with :os_type" do
    klass.new(:name => "p", :os_type => "unix").os_type.must_equal "unix"
    klass.new(:name => "p", :os_type => "windows").os_type.must_equal "windows"
    klass.new(:name => "p", :os_type => "unicorn").os_type.must_equal "unicorn"
    klass.new(:name => "p", :os_type => nil).os_type.must_equal nil
  end
end
