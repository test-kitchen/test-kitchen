# -*- encoding: utf-8 -*-

require "tmpdir"
require "pathname"

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar("GEM_HOME")
  backup_envvar("GEM_PATH")

  @aruba_timeout_seconds = 30

  gem_home = Pathname.new(Dir.mktmpdir(name))
  ENV["GEM_HOME"] = gem_home.to_s
  ENV["GEM_PATH"] = [gem_home.to_s, ENV["GEM_PATH"]].join(":")
  @cleanup_dirs << gem_home
end

Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, version|
  unbundlerize do
    run_simple(unescape("gem list #{name} --version #{version} -i"), true, nil)
  end
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  unbundlerize do
    run_simple(unescape("gem list #{name} -i"), true, nil)
  end
end
