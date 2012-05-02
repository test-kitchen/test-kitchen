require_relative '../../spec_helper'

require 'test-kitchen'

module TestKitchen

  module Project
    describe Ruby do
      describe "#runtimes" do
        it "defaults to ruby 1.9.2 if the language is ruby" do
          project = Ruby.new('foo')
          project.language = 'ruby'
          project.runtimes.must_equal ['1.9.2']
        end
      end
    end
  end
end
