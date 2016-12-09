# -*- encoding: utf-8 -*-
#
# Author:: Tyler Ball (<tball@chef.io>)
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

require_relative "../spec_helper"

require "kitchen/cli"
require "kitchen"

module Kitchen
  describe CLI do
    let(:cli) { CLI.new }

    before do
      @orig_env = ENV.to_hash
    end

    after do
      ENV.clear
      @orig_env.each do |k, v|
        ENV[k] = v
      end
    end

    describe "#initialize" do
      it "does not set logging config when environment variables are missing" do
        assert_equal Kitchen::DEFAULT_LOG_LEVEL, cli.config.log_level
        assert_equal Kitchen::DEFAULT_LOG_OVERWRITE, cli.config.log_overwrite
      end

      it "does set logging config when environment variables are present" do
        ENV["KITCHEN_LOG"] = "warn"
        ENV["KITCHEN_LOG_OVERWRITE"] = "false"

        assert_equal :warn, cli.config.log_level
        assert_equal false, cli.config.log_overwrite
      end
    end
  end
end
