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

gem 'minitest'

require 'simplecov'
SimpleCov.adapters.define 'gem' do
  command_name 'Specs'

  add_filter '.gem/'
  add_filter '/spec/'
  add_filter '/lib/vendor/'

  add_group 'Libraries', '/lib/'
end
SimpleCov.start 'gem'

require 'fakefs/safe'
require 'minitest/autorun'
require 'mocha/setup'
require 'tempfile'

# enable yaml symbol parsing if code is executing under guard
if ENV['GUARD_NOTIFY']
  if RUBY_VERSION <= "1.9.3"
    # ensure that Psych and not Syck is used for Ruby 1.9.2
    require 'yaml'
    YAML::ENGINE.yamler = 'psych'
  end
  require 'safe_yaml'
  YAML.enable_symbol_parsing!
  SafeYAML::OPTIONS[:suppress_warnings] = true
end

# Nasty hack to redefine IO.read in terms of File#read for fakefs
class IO
  def self.read(*args)
    File.open(args[0], "rb") { |f| f.read(args[1]) }
  end
end
