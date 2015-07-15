require 'spec_helper'

module Test
  module Prey
    module Mod; end
    class Base; end
    class Derived < Base
      include Mod
    end
  end
end

describe Scorpion::Prey do
  context "inheritance" do
    let( :prey ){ Scorpion::Prey.new( Test::Prey::Derived ) }

    it "matches more derived class when looking for base class" do
      expect( prey.satisfies? Test::Prey::Base ).to be_truthy
    end

    it "matches same class when looking for base class" do
      expect( prey.satisfies? Test::Prey::Derived ).to be_truthy
    end

    it "does not inherit symbols" do
      expect( Scorpion::Prey.new( :a ).satisfies? :b ).to be_falsy
    end

    it "can satisfy a module with a class" do
      expect( prey.satisfies? Test::Prey::Mod ).to be_truthy
    end

  end

  it "can satisfy symbol contracts" do
    expect( Scorpion::Prey.new( :symbol ).satisfies? :symbol ).to be_truthy
  end

  it "satisfies ignores tail hash traits" do
    expect( Scorpion::Prey.new( Test::Prey::Base ).satisfies?( Test::Prey::Base, ) )
  end

  describe "equality" do
    let( :prey )      { Scorpion::Prey.new( Test::Prey::Derived ) }
    let( :same )      { Scorpion::Prey.new( Test::Prey::Derived ) }
    let( :different ) { Scorpion::Prey.new( Test::Prey::Base ) }

    specify{ expect( prey ).to eq same }
    specify{ expect( prey ).not_to eq different }
    specify{ expect( prey.hash ).to eq same.hash }
  end

end