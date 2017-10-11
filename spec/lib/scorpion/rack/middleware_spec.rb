require "spec_helper"
require "scorpion/rack/middleware"

describe Scorpion::Rack::Middleware do
  let(:app)      { proc { [ 200, {}, [ "Sting!" ] ] } }
  let(:stack)    { Scorpion::Rack::Middleware.new( app ) }
  let(:request)  { Rack::MockRequest.new( stack ) }
  let(:response) { request.get("/") }

  it "creates a scorpion" do
    expect( stack ).to receive( :prepare_scorpion ).and_call_original
    response
  end

  it "prepares it with the environment" do
    proc = ->(env) {
        scorpion = env[Scorpion::Rack::Middleware::ENV_KEY]
        expect( scorpion.fetch( Scorpion::Rack::Env) ).to be env
      app.call( env )
    }

    request = Rack::MockRequest.new( Scorpion::Rack::Middleware.new( proc ) )
    request.get "/"
  end

  it "frees the scorpion on return" do
    expect( stack ).to receive( :free_scorpion ).and_call_original
    response
  end
end