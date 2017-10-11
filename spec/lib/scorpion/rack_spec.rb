require "spec_helper"
require "scorpion/rack"

describe Scorpion::Rack do
  it "it raises error when out of order" do
    klass = Class.new do
      include Scorpion::Rack

      def call( env )
        scorpion( env )
      end
    end

    expect do
      request = Rack::MockRequest.new( klass.new )
      request.get "/"
    end.to raise_error Scorpion::Rack::MissingScorpionError
  end
end