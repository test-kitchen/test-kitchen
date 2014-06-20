# -*- encoding: utf-8 -*-
#
# Author:: Chris Lundquist (<chris.lundquist@github.com>)
#
# Copyright (C) 2013, Chris Lundquist
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

require_relative '../../spec_helper'
require 'kitchen'

# Work around for lazy loading
require 'kitchen/provisioner/puppet_apply'

describe Kitchen::Provisioner::PuppetApply do
  let(:provisioner) do
    Kitchen::Provisioner.for_plugin("puppet_apply", {})
  end

  it "should give a sane run_command" do
    provisioner.run_command.must_match /puppet apply/
  end
end
