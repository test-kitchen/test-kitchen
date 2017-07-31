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
  let(:opts) { ; { name: "plata" }; }
  let(:klass) { Kitchen::Platform }

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { klass.new(opts) }.must_raise Kitchen::ClientError
  end

  it "#os_type returns value passed into constructor with :os_type" do
    klass.new(name: "p", os_type: "unix").os_type.must_equal "unix"
    klass.new(name: "p", os_type: "windows").os_type.must_equal "windows"
    klass.new(name: "p", os_type: "unicorn").os_type.must_equal "unicorn"
    klass.new(name: "p", os_type: nil).os_type.must_be_nil
  end

  it "#os_type defaults to `unix` when not provided" do
    klass.new(name: "p").os_type.must_equal "unix"
  end

  it "#os_type defaults to `windows` if the name starts with 'win'" do
    klass.new(name: "win").os_type.must_equal "windows"
    klass.new(name: "Win").os_type.must_equal "windows"
    klass.new(name: "win7").os_type.must_equal "windows"
    klass.new(name: "windows").os_type.must_equal "windows"
    klass.new(name: "Windows").os_type.must_equal "windows"
    klass.new(name: "windows81").os_type.must_equal "windows"
    klass.new(name: "windows-2012").os_type.must_equal "windows"
  end

  it "#shell_type returns value passed into constructor with :shell_type" do
    klass.new(name: "p", shell_type: "bourne")
         .shell_type.must_equal "bourne"
    klass.new(name: "p", shell_type: "powershell")
         .shell_type.must_equal "powershell"
    klass.new(name: "p", shell_type: "unicorn")
         .shell_type.must_equal "unicorn"
    klass.new(name: "p", shell_type: nil)
         .shell_type.must_be_nil
  end

  it "#shell_type defaults to `bourne` when not provided" do
    klass.new(name: "p").shell_type.must_equal "bourne"
  end

  it "#shell_type defaults to `powershell` if the name starts with 'windows'" do
    klass.new(name: "win").shell_type.must_equal "powershell"
    klass.new(name: "Win").shell_type.must_equal "powershell"
    klass.new(name: "win7").shell_type.must_equal "powershell"
    klass.new(name: "windows").shell_type.must_equal "powershell"
    klass.new(name: "Windows").shell_type.must_equal "powershell"
    klass.new(name: "windows81").shell_type.must_equal "powershell"
    klass.new(name: "windows-2012").shell_type.must_equal "powershell"
  end

  it "#diagnose returns a hash with sorted keys" do
    opts[:os_type] = "unikitty"
    opts[:shell_type] = "wundershell"

    klass.new(opts).diagnose.must_equal(
      os_type: "unikitty",
      shell_type: "wundershell"
    )
  end
end
