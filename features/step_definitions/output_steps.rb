# -*- encoding: utf-8 -*-

Then(/^the stdout should match \/([^\/]*)\/$/) do |expected|
  assert_matching_output(expected, all_stdout)
end
