# -*- encoding: utf-8 -*-
#
# Author:: Fletcher (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require_relative "../../../spec_helper"

require "kitchen"
require "kitchen/transport/winrm/template"

describe Kitchen::Transport::Winrm::Template do

  let(:path) { "/tmp/tmpl.erb" }

  let(:template) do
    Kitchen::Transport::Winrm::Template.new(path)
  end

  it "#render returns the ERb template rendered with the hash context" do
    with_fake_fs do
      create_template(path)
      template.render(:greeting => "Hello", :user => "Fletcher").
        must_equal "Hello, Fletcher!"
    end
  end

  it "#% returns the ERb template rendered with the hash context" do
    with_fake_fs do
      create_template(path)
      (template % { :greeting => "Hello", :user => "Fletcher" }).
        must_equal "Hello, Fletcher!"
    end
  end

  def create_template(path)
    File.open(path, "wb") { |f| f.write("<%= greeting %>, <%= user %>!") }
  end
end
