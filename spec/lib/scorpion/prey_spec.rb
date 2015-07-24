require 'spec_helper'

module Test
  module Prey
    module Mod; end
    class Base; end
    class Derived < Base
      include Mod
    end

    class Footwear
      def self.hunt( scorpion, *args, &block )
        yield
      end
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

  describe "traits" do

    context "symbolic" do
      let( :prey ){ Scorpion::Prey.new Test::Prey::Base, :apples }
      it "satisfies matched traits" do
        expect( prey.satisfies? Test::Prey::Base, :apples ).to be_truthy
      end

      it "doesn't satisfy mis-matched traits" do
        expect( prey.satisfies? Test::Prey::Base, :oranges ).to be_falsy
      end
    end

    context "module" do
      let( :prey ){ Scorpion::Prey.new Test::Prey::Derived }

      it "satisfies module traits" do
        expect( prey.satisfies? Test::Prey::Base, Test::Prey::Derived ).to be_truthy
      end
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

  describe ".define" do
    let( :scorpion ){ double Scorpion }

    it "is a ClassPrey for class hunts" do
      prey = Scorpion::Prey.define String
      expect( prey ).to be_a Scorpion::Prey::ClassPrey
    end

    it "is a ModulePrey for module hunts" do
      prey = Scorpion::Prey.define Test::Prey::Mod
      expect( prey ).to be_a Scorpion::Prey::ModulePrey
    end

    it "is a BuilderPrey for capture instances" do
      prey = Scorpion::Prey.define String, capture: "AWESEOME"

      expect( prey ).to be_a Scorpion::Prey::BuilderPrey
      expect( prey.fetch scorpion ).to eq "AWESEOME"
    end

    it "is a BuilderPrey for block hunts" do
      prey =  Scorpion::Prey.define String do
                "YASS"
              end

      expect( prey ).to be_a Scorpion::Prey::BuilderPrey
    end

    it "is a BuilderPrey for with: option" do
      prey = Scorpion::Prey.define String, with: ->(scorpion,*args,&block){ "YASSS" }

      expect( prey ).to be_a Scorpion::Prey::BuilderPrey
      expect( prey.fetch scorpion ).to eq "YASSS"
    end

    it "is a BuilderPrey when hunted class implements #hunt" do
      prey = Scorpion::Prey.define Test::Prey::Footwear

      expect( prey ).to be_a Scorpion::Prey::BuilderPrey
      expect( prey.fetch( scorpion ) {"Nike"} ).to eq "Nike"
    end

  end

end