#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/provisioner/chef_base"
require "fileutils"
require "mixlib/install"
require "mixlib/install/script_generator"

describe Kitchen::Provisioner::ChefBase do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(os_type: nil) }
  let(:driver)          { stub(cache_directory: nil) }
  let(:suite)           { stub(name: "fries") }

  let(:config) do
    { test_base_path: "/basist", kitchen_root: "/rooty" }
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      logger: logger,
      suite: suite,
      platform: platform,
      driver: driver
    )
  end

  let(:provisioner) do
    Class.new(Kitchen::Provisioner::ChefBase) do
      def calculate_path(path, _opts = {})
        "<calculated>/#{path}"
      end
    end.new(config).finalize_config!(instance)
  end

  describe "configuration" do
    describe "for unix operating systems" do
      before { platform.stubs(:os_type).returns("unix") }

      it ":chef_omnibus_url has a default" do
        _(provisioner[:chef_omnibus_url]).must_equal "https://omnitruck.cinc.sh/install.sh"
      end
    end

    describe "for windows operating systems" do
      before { platform.stubs(:os_type).returns("windows") }

      it ":chef_omnibus_url has a default" do
        _(provisioner[:chef_omnibus_url]).must_equal "https://omnitruck.cinc.sh/install.sh"
      end
    end

    it ":require_chef_omnibus defaults to true" do
      _(provisioner[:require_chef_omnibus]).must_equal true
    end

    it ":chef_omnibus_install_options defaults to nil" do
      _(provisioner[:chef_omnibus_install_options]).must_be_nil
    end

    it ":run_list defaults to an empty array" do
      _(provisioner[:run_list]).must_equal []
    end

    it ":attributes defaults to an empty hash" do
      _(provisioner[:attributes]).must_equal({})
    end

    it ":log_level defaults to auto" do
      _(provisioner[:log_level]).must_equal "auto"
    end

    it ":product_name defaults to nil" do
      _(provisioner[:product_name]).must_be_nil
    end

    it ":product_version defaults to :latest" do
      _(provisioner[:product_version]).must_equal :latest
    end

    it ":channel defaults to :stable" do
      _(provisioner[:channel]).must_equal :stable
    end

    it ":install_strategy defaults to 'once'" do
      _(provisioner[:install_strategy]).must_equal "once"
    end

    it ":chef_license_key defaults to nil" do
      _(provisioner[:chef_license_key]).must_be_nil
    end

    it ":download_url uses omnibus_download_url" do
      provisioner.expects(:omnibus_download_url).returns("test_url")
      _(provisioner[:download_url]).must_equal "test_url"
    end

    describe ":chef_omnibus_root" do
      it "defaults based on product_name" do
        config[:product_name] = "chef"
        _(provisioner[:chef_omnibus_root]).must_equal "/opt/chef"
      end

      it "defaults to nil when product_name is nil" do
        config[:product_name] = nil
        _(provisioner[:chef_omnibus_root]).must_be_nil
      end
    end
  end

  describe "deprecation warnings" do
    # These tests just verify that deprecated configs don't break the provisioner
    it "accepts require_chef_omnibus when false" do
      config[:require_chef_omnibus] = false
      provisioner # Should not raise an error
    end

    it "accepts require_chef_omnibus with version values" do
      config[:require_chef_omnibus] = "15.0.0"
      provisioner # Should not raise an error
    end

    it "accepts chef_omnibus_install_options deprecation" do
      config[:chef_omnibus_install_options] = "-P chef"
      provisioner # Should not raise an error
    end
  end

  describe "#install_command" do
    before do
      platform.stubs(:shell_type).returns("bourne")
      platform.stubs(:os_type).returns("unix")
    end

    let(:cmd) { provisioner.install_command }

    it "returns nil if :require_chef_omnibus is falsey" do
      config[:require_chef_omnibus] = false
      config[:product_name] = nil
      _(cmd).must_be_nil
    end

    it "returns nil if :product_name is set and :install_strategy is skip" do
      config[:product_name] = "chef"
      config[:install_strategy] = "skip"
      _(cmd).must_be_nil
    end

    it "returns a command if :require_chef_omnibus is true" do
      config[:require_chef_omnibus] = true
      config[:product_name] = nil
      _(cmd).wont_be_nil
      _(cmd).must_be_kind_of String
    end

    describe "when using product_name" do
      before do
        config[:product_name] = "chef"
        config[:chef_license_key] = "test-key"
        config[:require_chef_omnibus] = nil
      end

      it "returns a command when product_name is set" do
        result = provisioner.install_command
        _(result).wont_be_nil
        _(result).must_be_kind_of String
      end

      it "returns nil when install_strategy is skip" do
        config[:install_strategy] = "skip"
        result = provisioner.install_command
        _(result).must_be_nil
      end
    end
  end

  describe "#product_version" do
    describe "when require_chef_omnibus is true and product_version is not set" do
      it "returns :latest" do
        config[:require_chef_omnibus] = true
        _(provisioner.product_version).must_equal :latest
      end
    end

    describe "when require_chef_omnibus is false and product_version is nil" do
      it "returns nil" do
        config[:product_version] = nil
        config[:require_chef_omnibus] = false
        _(provisioner.product_version).must_be_nil
      end
    end

    describe "when require_chef_omnibus is a string" do
      it "returns the require_chef_omnibus string" do
        config[:require_chef_omnibus] = "15.0.0"
        _(provisioner.product_version).must_match "15.0.0"
      end
    end

    describe "when product_version is set" do
      it "returns the product_version string" do
        config[:product_version] = "15.0.0"
        _(provisioner.product_version).must_match "15.0.0"
      end
    end
  end

  describe "#check_license_key" do
    describe "when product_name starts with 'chef' and version >= 15" do
      before do
        config[:product_name] = "chef-workstation"
        config[:product_version] = 15
      end

      it "raises an error when chef_license_key is nil" do
        config[:chef_license_key] = nil
        expect { provisioner.check_license_key }.must_raise(RuntimeError)
      end

      it "raises an error when chef_license_key is empty" do
        config[:chef_license_key] = ""
        expect { provisioner.check_license_key }.must_raise(RuntimeError)
      end

      it "does not raise when chef_license_key is present" do
        config[:chef_license_key] = "valid-key"
        # This should not raise an error
        provisioner.check_license_key
      end
    end

    describe "when product_name starts with 'chef' and version < 15" do
      before do
        config[:product_name] = "chef-workstation"
        config[:product_version] = 14
      end

      it "does not raise an error when chef_license_key is nil" do
        config[:chef_license_key] = nil
        # This should not raise an error for versions < 15
        provisioner.check_license_key
      end
    end

    describe "when product_name does not start with 'chef'" do
      before do
        config[:product_name] = "cinc-workstation"
        config[:product_version] = 15
      end

      it "does not raise an error when chef_license_key is nil" do
        config[:chef_license_key] = nil
        # This should not raise an error for non-chef products
        provisioner.check_license_key
      end

      it "does not raise an error when chef_license_key is empty" do
        config[:chef_license_key] = ""
        # This should not raise an error for non-chef products
        provisioner.check_license_key
      end
    end

    describe "when product_name is nil" do
      before do
        config[:product_name] = nil
        config[:product_version] = 15
      end

      it "does not raise an error when chef_license_key is nil" do
        config[:chef_license_key] = nil
        # This should not raise an error when product_name is nil
        provisioner.check_license_key
      end
    end
  end

  describe "#omnitruck_base_url" do
    describe "when product_name starts with 'chef'" do
      before do
        config[:product_name] = "chef-workstation"
        config[:product_version] = "latest"
      end

      it "returns the commercial Chef download URL" do
        _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-commercial.chef.io"
      end

      describe "with version 14 or lower" do
        it "returns community URL for version 14" do
          config[:product_version] = 14
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-community.chef.io"
        end

        it "returns community URL for version 13" do
          config[:product_version] = 13
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-community.chef.io"
        end

        it "returns community URL for version '14.0.0'" do
          config[:product_version] = "14.0.0"
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-community.chef.io"
        end
      end

      describe "with version 15 or above" do
        it "returns commercial URL for version 15" do
          config[:product_version] = 15
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-commercial.chef.io"
        end

        it "returns commercial URL for version 16" do
          config[:product_version] = 16
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-commercial.chef.io"
        end

        it "returns commercial URL for version '15.0.0'" do
          config[:product_version] = "15.0.0"
          _(provisioner.omnitruck_base_url).must_equal "https://chefdownload-commercial.chef.io"
        end
      end
    end

    describe "when product_name starts with 'cinc'" do
      before { config[:product_name] = "cinc-workstation" }

      it "returns the CINC download URL" do
        _(provisioner.omnitruck_base_url).must_equal "https://omnitruck.cinc.sh"
      end
    end

    describe "when product_name is something else" do
      before { config[:product_name] = "other-product" }

      it "returns the default omnitruck URL" do
        _(provisioner.omnitruck_base_url).must_equal "https://omnitruck.cinc.sh"
      end
    end

    describe "when product_name is nil" do
      before { config[:product_name] = nil }

      it "returns the default omnitruck URL" do
        _(provisioner.omnitruck_base_url).must_equal "https://omnitruck.cinc.sh"
      end
    end
  end

  describe "#omnibus_download_url" do
    describe "when product_name starts with 'chef' and version >= 15" do
      before do
        config[:product_name] = "chef"
        config[:product_version] = "latest"
        config[:chef_license_key] = "test-key"
      end

      it "returns commercial URL with license key" do
        expected = "https://chefdownload-commercial.chef.io/install.sh?license_id=test-key"
        _(provisioner.omnibus_download_url).must_equal expected
      end

      it "calls check_license_key" do
        provisioner.expects(:check_license_key)
        provisioner.omnibus_download_url
      end
    end

    describe "when product_name starts with 'chef' and version < 15" do
      before do
        config[:product_name] = "chef"
        config[:product_version] = "14"
      end

      it "returns community URL" do
        expected = "https://chefdownload-community.chef.io/install.sh"
        _(provisioner.omnibus_download_url).must_equal expected
      end
    end

    describe "when product_name is nil or doesn't start with 'chef'" do
      before { config[:product_name] = nil }

      it "returns CINC URL" do
        expected = "https://omnitruck.cinc.sh/install.sh"
        _(provisioner.omnibus_download_url).must_equal expected
      end
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
