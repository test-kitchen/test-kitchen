require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require_relative '../lib/test-kitchen'
