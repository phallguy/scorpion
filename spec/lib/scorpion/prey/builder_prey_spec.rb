require 'spec_helper'

module Test
  module BuilderPrey
    class ClassDelegate
      def call( scorpion, *args, &block )
        Test
      end
    end

    module ModDelegate
      module_function

      def call( scorpion, *args, &block )
        Test
      end
    end
  end
end

describe Scorpion::Prey::BuilderPrey do
  let( :scorpion ){ double }

  it "supports class hunting delegates" do
    prey = Scorpion::Prey::BuilderPrey.new( String, nil, Test::BuilderPrey::ClassDelegate.new )
    expect( prey.fetch( scorpion ) ).to be Test
  end

  it "supports module hunting delegates" do
    prey = Scorpion::Prey::BuilderPrey.new( String, nil, Test::BuilderPrey::ModDelegate )
    expect( prey.fetch( scorpion ) ).to be Test
  end

  it "supports block hunting delegates" do
    prey = Scorpion::Prey::BuilderPrey.new( String, nil ) do
      Test
    end
    expect( prey.fetch( scorpion ) ).to be Test
  end


end