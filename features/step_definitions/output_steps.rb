# frozen_string_literal: true

Then(%r{^the stdout should match /([^/]*)/$}) do |expected|
  expect(last_command_started).to have_output_on_stdout(Regexp.new(expected))
end
