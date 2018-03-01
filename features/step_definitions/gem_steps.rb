# -*- encoding: utf-8 -*-

require "tmpdir"
require "pathname"

Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, version|
  unbundlerize do
    run_simple(
      sanitize_text("gem list #{name} --version #{version} -i"),
      fail_on_error: true,
      exit_timeout: nil
    )
  end
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  unbundlerize do
    run_simple(
      sanitize_text("gem list #{name} -i"),
      fail_on_error: true,
      exit_timeout: nil
    )
  end
end
