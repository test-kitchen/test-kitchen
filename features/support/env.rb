require 'aruba/cucumber'

require 'minitest/spec'

World(MiniTest::Assertions)
MiniTest::Spec.new(nil)

Before do
  @aruba_timeout_seconds = 60 * 30
end
