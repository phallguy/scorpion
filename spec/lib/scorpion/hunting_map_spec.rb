require 'spec_helper'

module Test
  module HuntingMap
    class Weapon; end
    class Armor; end
  end
end

describe Scorpion::HuntingMap do
  let( :scorpion ){ double Scorpion }
  let( :map ){ Scorpion::HuntingMap.new scorpion }

  describe "#chart" do
    it "yields itself when arg expected" do
      map.chart do |itself|
        expect( map ).to be itself
      end
    end
  end

  describe "#find" do
    it "returns a match" do
      map.chart do
        hunt_for Test::HuntingMap::Weapon
        hunt_for Test::HuntingMap::Armor
      end

      expect( map.find( Test::HuntingMap::Armor ).contract ).to eq Test::HuntingMap::Armor
    end

    it "returns nil when no match" do
      map.chart do
        hunt_for Test::HuntingMap::Weapon
      end

      expect( map.find( Test::HuntingMap::Armor ) ).to be_nil
    end

    it "returns nil when no match" do
      map.chart do
        hunt_for Test::HuntingMap::Weapon
      end

      expect( map.find( Test::HuntingMap::Armor ) ).to be_nil
    end


    context "multiple possible matches" do
      before( :each ) do
        map.chart do
          hunt_for Test::HuntingMap::Weapon, [ :sharp, :one_handed ]
          hunt_for Test::HuntingMap::Weapon, [ :blunt, :one_handed ]
        end
      end

      it "returns the last prey that matches one trait" do
        expect( map.find( Test::HuntingMap::Weapon, :one_handed ).traits ).to include :blunt
      end

      it "returns the last prey that matches all of the traits" do
        expect( map.find( Test::HuntingMap::Weapon, [ :one_handed, :blunt ] ).traits ).to include :blunt
      end

      it "returns the last prey that matches a unique trait" do
        expect( map.find( Test::HuntingMap::Weapon, :blunt ).traits ).to include :blunt
      end
    end
  end

  describe "#hunt_for" do
    it "adds a Prey" do
      expect( map ).to be_empty

      map.chart do
        hunt_for Test::HuntingMap::Weapon
      end

      expect( map.first ).to be_a Scorpion::Prey
    end

    it "adds a BuilderPrey for block hunts" do
      map.chart do
        hunt_for String do
          "YASS"
        end
      end

      expect( map.first ).to be_a Scorpion::Prey::BuilderPrey
    end

    it "adds a BuilderPrey for with: option" do
      map.chart do
        hunt_for String, with: ->(scorpion,*args,&block){ "YASSS" }
      end

      expect( map.first ).to be_a Scorpion::Prey::BuilderPrey
    end
<<<<<<< Updated upstream
=======

    it "adds a BuilderPrey when hunted class implements #hunt" do
      map.chart do
        hunt_for Test::HuntingMap::Footwear
      end

      expect( map.first ).to be_a Scorpion::Prey::BuilderPrey
      expect( map.find( Test::HuntingMap::Footwear ).fetch( scorpion ) {"Nike"} ).to eq "Nike"
    end
>>>>>>> Stashed changes
  end

  describe "#replicate_from" do
    it "does not dup shared prey" do
      map.chart do
        share do
          capture Test::HuntingMap::Weapon
        end
      end

      replica = Scorpion::HuntingMap.new scorpion
      replica.replicate_from( map )

      expect( replica ).to be_empty
    end

    it "dups captured prey" do
      map.chart do
        capture Test::HuntingMap::Weapon
      end

      replica = Scorpion::HuntingMap.new scorpion
      replica.replicate_from( map )

      expect( replica ).not_to be_empty
    end
  end
end