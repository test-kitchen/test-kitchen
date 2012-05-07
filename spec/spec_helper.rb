require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

SimpleCov.at_exit do
  SimpleCov.result.format!
  if SimpleCov.result.covered_percent < 66
    warn "Coverage is slipping: #{SimpleCov.result.covered_percent.to_i}%"
    exit 1
  end
end

require_relative '../lib/test-kitchen'
