# -*- encoding: utf-8 -*-

require "tmpdir"
require "pathname"

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar("GEM_HOME")
  backup_envvar("GEM_PATH")

  @aruba_timeout_seconds = 30

  gem_home = Pathname.new(Dir.mktmpdir(name))
  aruba.environment["GEM_HOME"] = gem_home.to_s
  aruba.environment["GEM_PATH"] = [gem_home.to_s, ENV["GEM_PATH"]].join(":")
  @cleanup_dirs << gem_home
end

Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, version|
  unbundlerize do
    run_simple(
      sanitize_text("gem list #{name} --version #{version} -i"),
      :fail_on_error => true,
      :exit_timeout => nil
     )
  end
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  unbundlerize do
    run_simple(
      sanitize_text("gem list #{name} -i"),
      :fail_on_error => true,
      :exit_timeout => nil
     )
  end
end
