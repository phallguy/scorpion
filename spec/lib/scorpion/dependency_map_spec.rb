require 'spec_helper'

module Test
  module DependencyMap
    class Weapon; end
    class Armor; end
  end
end

describe Scorpion::DependencyMap do
  let( :scorpion ){ double Scorpion }
  let( :map ){ Scorpion::DependencyMap.new scorpion }

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
        hunt_for Test::DependencyMap::Weapon
        hunt_for Test::DependencyMap::Armor
      end

      expect( map.find( Test::DependencyMap::Armor ).contract ).to eq Test::DependencyMap::Armor
    end

    it "returns nil when no match" do
      map.chart do
        hunt_for Test::DependencyMap::Weapon
      end

      expect( map.find( Test::DependencyMap::Armor ) ).to be_nil
    end

    it "returns nil when no match" do
      map.chart do
        hunt_for Test::DependencyMap::Weapon
      end

      expect( map.find( Test::DependencyMap::Armor ) ).to be_nil
    end


    context "multiple possible matches" do
      before( :each ) do
        map.chart do
          hunt_for Test::DependencyMap::Weapon, [ :sharp, :one_handed ]
          hunt_for Test::DependencyMap::Weapon, [ :blunt, :one_handed ]
        end
      end

      it "returns the last dependency that matches one trait" do
        expect( map.find( Test::DependencyMap::Weapon, :one_handed ).traits ).to include :blunt
      end

      it "returns the last dependency that matches all of the traits" do
        expect( map.find( Test::DependencyMap::Weapon, [ :one_handed, :blunt ] ).traits ).to include :blunt
      end

      it "returns the last dependency that matches a unique trait" do
        expect( map.find( Test::DependencyMap::Weapon, :blunt ).traits ).to include :blunt
      end
    end
  end

  describe "#hunt_for" do
    it "adds a Dependency" do
      expect( map ).to be_empty

      map.chart do
        hunt_for Test::DependencyMap::Weapon
      end

      expect( map.first ).to be_a Scorpion::Dependency
    end
  end

  describe "#replicate_from" do
    it "does not dup shared dependency" do
      # Instead of duping shared dependencies, the scorpion should delegate to
      # its parent which shares the same instance with all of its children.
      map.chart do
        share do
          capture Test::DependencyMap::Weapon
        end
      end

      replica = Scorpion::DependencyMap.new scorpion
      replica.replicate_from( map )

      expect( replica ).to be_empty
    end

    it "dups captured dependency" do
      map.chart do
        capture Test::DependencyMap::Weapon
      end

      replica = Scorpion::DependencyMap.new scorpion
      replica.replicate_from( map )

      expect( replica ).not_to be_empty
    end
  end
end