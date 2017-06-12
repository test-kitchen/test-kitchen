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

require_relative "../spec_helper"

# There is some double Base64 encoding going on when a PowerShell script is
# given to a CMD to invoke. We're in a battle with Windows' CMD max length and
# that what these specs are trying to ensure. This does lead to some less than
# ideal "code golfing" to reduce the code payload, but at the end of the day
# it's easier to see the entire context of the code vs. uploading partial code
# fragements and calling them on the remote side (not to mention more expensive
# in terms of PowerShell invocations).

describe "PowerShell script max size" do
  MAX_POWERSHELL_SIZE = 3010

  Dir.glob(File.join(File.dirname(__FILE__), "../../support/*.ps1*")).each do |script|
    base = File.basename(script)

    it "support/#{base} size must be less than #{MAX_POWERSHELL_SIZE} bytes" do
      (IO.read(script).size < MAX_POWERSHELL_SIZE).must_equal true
    end
  end
end
