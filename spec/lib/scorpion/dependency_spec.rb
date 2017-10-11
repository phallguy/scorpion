require "spec_helper"

module Test
  module Dependency
    module Mod; end
    class Base; end
    class Derived < Base
      include Mod
    end

    class Footwear
      def self.create( scorpion, *args, &block )
        yield
      end
    end

  end
end

describe Scorpion::Dependency do
  context "inheritance" do
    let( :dependency ) { Scorpion::Dependency.new( Test::Dependency::Derived ) }

    it "matches more derived class when looking for base class" do
      expect( dependency.satisfies?(Test::Dependency::Base) ).to be_truthy
    end

    it "matches same class when looking for base class" do
      expect( dependency.satisfies?(Test::Dependency::Derived) ).to be_truthy
    end

    it "does not inherit symbols" do
      expect( Scorpion::Dependency.new( :a ).satisfies?(:b) ).to be_falsy
    end

    it "can satisfy a module with a class" do
      expect( dependency.satisfies?(Test::Dependency::Mod) ).to be_truthy
    end

  end

  describe "traits" do

    context "symbolic" do
      let( :dependency ) { Scorpion::Dependency.new Test::Dependency::Base, :apples }
      it "satisfies matched traits" do
        expect( dependency.satisfies?(Test::Dependency::Base, :apples) ).to be_truthy
      end

      it "doesn't satisfy mis-matched traits" do
        expect( dependency.satisfies?(Test::Dependency::Base, :oranges) ).to be_falsy
      end
    end

    context "module" do
      let( :dependency ) { Scorpion::Dependency.new Test::Dependency::Derived }

      it "satisfies module traits" do
        expect( dependency.satisfies?(Test::Dependency::Base, Test::Dependency::Derived) ).to be_truthy
      end
    end

  end

  it "can satisfy symbol contracts" do
    expect( Scorpion::Dependency.new( :symbol ).satisfies?(:symbol) ).to be_truthy
  end

  it "satisfies ignores tail hash traits" do
    expect( Scorpion::Dependency.new( Test::Dependency::Base ).satisfies?( Test::Dependency::Base ) )
  end

  describe "equality" do
    let( :dependency ) { Scorpion::Dependency.new( Test::Dependency::Derived ) }
    let( :same )      { Scorpion::Dependency.new( Test::Dependency::Derived ) }
    let( :different ) { Scorpion::Dependency.new( Test::Dependency::Base ) }

    specify { expect( dependency ).to eq same }
    specify { expect( dependency ).not_to eq different }
    specify { expect( dependency.hash ).to eq same.hash }
  end

  describe ".define" do
    let( :scorpion ) { double Scorpion }
    let( :hunt ) { Scorpion::Hunt.new scorpion, String, nil }

    it "is a ClassDependency for class hunts" do
      dependency = Scorpion::Dependency.define String
      expect( dependency ).to be_a Scorpion::Dependency::ClassDependency
    end

    it "is a ModuleDependency for module hunts" do
      dependency = Scorpion::Dependency.define Test::Dependency::Mod
      expect( dependency ).to be_a Scorpion::Dependency::ModuleDependency
    end

    it "is a BuilderDependency for return: instances" do
      dependency = Scorpion::Dependency.define String, return: "AWESEOME"

      expect( dependency ).to be_a Scorpion::Dependency::BuilderDependency
      expect( dependency.fetch(hunt) ).to eq "AWESEOME"
    end

    it "is a BuilderDependency for block hunts" do
      dependency =  Scorpion::Dependency.define String do
                "YASS"
      end

      expect( dependency ).to be_a Scorpion::Dependency::BuilderDependency
    end

    it "is a BuilderDependency for with: option" do
      dependency = Scorpion::Dependency.define String, with: ->(_scorpion, *_args) { "YASSS" }

      expect( dependency ).to be_a Scorpion::Dependency::BuilderDependency
      expect( dependency.fetch(hunt) ).to eq "YASSS"
    end

    it "is a BuilderDependency when hunted class implements #create" do
      dependency = Scorpion::Dependency.define Test::Dependency::Footwear
      hunt = Scorpion::Hunt.new scorpion, String, nil do
        "Nike"
      end

      expect( dependency ).to be_a Scorpion::Dependency::BuilderDependency
      expect( dependency.fetch( hunt ) ).to eq "Nike"
    end

  end

end