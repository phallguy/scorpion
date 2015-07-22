require 'spec_helper'

describe Scorpion::Prey::ArgumentPrey do
  let( :prey ) { Scorpion::Prey::ArgumentPrey.new( arg ) }
  let( :arg )  { "Hello" }

  it "matches the same type" do
    expect( prey.satisfies?( String ) ).to be_truthy
  end

  it "doesn't match different types" do
    expect( prey.satisfies?( Regexp ) ).to be_falsy
  end

  it "doesn't match traits" do
    expect( prey.satisfies?( String, :password ) ).to be_falsy
  end
end