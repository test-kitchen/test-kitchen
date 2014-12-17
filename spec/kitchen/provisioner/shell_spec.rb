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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/provisioner/shell"

describe Kitchen::Provisioner::Shell do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:config) do
    { :test_base_path => "/basist", :kitchen_root => "/rooty" }
  end

  let(:suite) do
    stub(:name => "fries")
  end

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :suite => suite)
  end

  let(:provisioner) do
    Class.new(Kitchen::Provisioner::Shell) {
      def calculate_path(path, _opts = {})
        "<calculated>/#{path}"
      end
    }.new(config).finalize_config!(instance)
  end

  describe "configuration" do

    it ":script uses calculate_path and is expanded" do
      provisioner[:script].must_equal "/rooty/<calculated>/bootstrap.sh"
    end

    it ":data_path uses calculate_path and is expanded" do
      provisioner[:data_path].must_equal "/rooty/<calculated>/data"
    end
  end

  describe "#init_command" do

    let(:cmd) { provisioner.init_command }

    it "uses bourne shell" do
      cmd.must_match(/\Ash -c '$/)
      cmd.must_match(/'\Z/)
    end

    it "uses sudo for rm when configured" do
      config[:sudo] = true

      cmd.must_match regexify("sudo -E rm -rf ", :partial_line)
    end

    it "does not use sudo for rm when configured" do
      config[:sudo] = false

      provisioner.init_command.
        must_match regexify("rm -rf ", :partial_line)
      provisioner.init_command.
        wont_match regexify("sudo -E rm -rf ", :partial_line)
    end

    it "removes the data directory" do
      config[:root_path] = "/route"

      cmd.must_match %r{rm -rf\b.*\s+/route/data\s+}
    end

    it "creates :root_path directory" do
      config[:root_path] = "/root/path"

      cmd.must_match regexify("mkdir -p /root/path", :partial_line)
    end
  end

  describe "#run_command" do

    let(:cmd) { provisioner.run_command }

    it "uses bourne shell" do
      cmd.must_match(/\Ash -c '$/)
      cmd.must_match(/'\Z/)
    end

    it "uses sudo for script when configured" do
      config[:root_path] = "/r"
      config[:sudo] = true

      cmd.must_match regexify("sudo -E /r/bootstrap.sh", :partial_line)
    end

    it "does not use sudo for script when configured" do
      config[:root_path] = "/r"
      config[:sudo] = false

      cmd.must_match regexify("/r/bootstrap.sh", :partial_line)
      cmd.wont_match regexify("sudo -E /r/bootstrap.sh", :partial_line)
    end
  end

  describe "#create_sandbox" do

    before do
      @root = Dir.mktmpdir
      config[:kitchen_root] = @root
    end

    after do
      FileUtils.remove_entry(@root)
      begin
        provisioner.cleanup_sandbox
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    let(:provisioner) do
      Kitchen::Provisioner::Shell.new(config).finalize_config!(instance)
    end

    describe "data files" do

      before do
        create_files_under("#{config[:kitchen_root]}/my_data")
        config[:data_path] = "#{config[:kitchen_root]}/my_data"
      end

      it "skips directory creation if :data_path is not set" do
        config[:data_path] = nil
        provisioner.create_sandbox

        sandbox_path("data").directory?.must_equal false
      end

      it "copies tree from :data_path into sandbox" do
        provisioner.create_sandbox

        sandbox_path("data/alpha.txt").file?.must_equal true
        IO.read(sandbox_path("data/alpha.txt")).must_equal "stuff"
        sandbox_path("data/sub").directory?.must_equal true
        sandbox_path("data/sub/bravo.txt").file?.must_equal true
        IO.read(sandbox_path("data/sub/bravo.txt")).must_equal "junk"
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        logged_output.string.must_match info_line("Preparing data")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        logged_output.string.must_match debug_line(
          "Using data from #{config[:kitchen_root]}/my_data")
      end
    end

    describe "script file" do

      describe "with a valid :script file" do

        before do
          File.open("#{config[:kitchen_root]}/my_script", "wb") do |file|
            file.write("gonuts")
          end
          config[:script] = "#{config[:kitchen_root]}/my_script"
        end

        it "creates a file in the sandbox directory" do
          provisioner.create_sandbox

          sandbox_path("my_script").file?.must_equal true
          sandbox_path("my_script").executable?.must_equal true
          IO.read(sandbox_path("my_script")).must_equal "gonuts"
        end

        it "logs a message on info" do
          provisioner.create_sandbox

          logged_output.string.must_match info_line("Preparing script")
        end

        it "logs a message on debug" do
          provisioner.create_sandbox

          logged_output.string.must_match debug_line(
            "Using script from #{config[:kitchen_root]}/my_script")
        end
      end

      describe "with no :script file" do

        before { config[:script] = nil }

        it "logs a message on info" do
          provisioner.create_sandbox

          logged_output.string.must_match info_line("Preparing script")
        end

        it "logs a warning on info" do
          provisioner.create_sandbox

          logged_output.string.must_match info_line(
            "bootstrap.sh not found so Kitchen will run a stubbed script. " \
            "Is this intended?")
        end

        it "creates a file in the sandbox directory" do
          provisioner.create_sandbox

          sandbox_path("bootstrap.sh").file?.must_equal true
          sandbox_path("bootstrap.sh").executable?.must_equal true
          IO.read(sandbox_path("bootstrap.sh")).
            must_match(/NO BOOTSTRAP SCRIPT PRESENT/)
        end
      end
    end

    def sandbox_path(path)
      Pathname.new(provisioner.sandbox_path).join(path)
    end

    def create_files_under(path)
      FileUtils.mkdir_p(File.join(path, "sub"))
      File.open(File.join(path, "alpha.txt"), "wb") do |file|
        file.write("stuff")
      end
      File.open(File.join(path, "sub", "bravo.txt"), "wb") do |file|
        file.write("junk")
      end
    end

    def info_line(msg)
      %r{^I, .* : #{Regexp.escape(msg)}$}
    end

    def debug_line(msg)
      %r{^D, .* : #{Regexp.escape(msg)}$}
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
