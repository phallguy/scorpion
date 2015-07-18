require 'spec_helper'

module Test
  module Hunter
    class Beast; end
    class Bear < Beast; end
    class Lion < Beast; end
    class Grizly < Bear; end
    class Argumented
      def initialize( arg )
        @arg = arg
      end
      attr_reader :arg
    end
    class Implicit; end

    class Zoo
      include Scorpion::King

      feed_on do
        bear Bear
      end
    end
  end
end

describe Scorpion::Hunter do

  let( :hunter ) do
    Scorpion::Hunter.new do
      hunt_for Test::Hunter::Bear
      hunt_for Test::Hunter::Lion, :male
      hunt_for Test::Hunter::Grizly, :female
      hunt_for Test::Hunter::Argumented

      capture Test::Hunter::Lion, :tame
      hunt_for Test::Hunter::Zoo
    end
  end

  it "spawns prey" do
    expect( hunter.hunt! Test::Hunter::Beast ).to be_a Test::Hunter::Bear
  end

  it "spawns a new instance for multiple requests" do
    first = hunter.hunt! Test::Hunter::Beast
    expect( hunter.hunt! Test::Hunter::Beast ).not_to eq first
  end

  it "spawns the same instance for captured prey" do
    first = hunter.hunt_by_traits! Test::Hunter::Beast, :tame
    expect( hunter.hunt_by_traits! Test::Hunter::Beast, :tame ).to be first
  end

  it "injects nested kings" do
    zoo = hunter.hunt! Test::Hunter::Zoo
    expect( zoo.bear ).to be_a Test::Hunter::Bear
  end

  it "accepts arguments that are passed to constructor" do
    obj = hunter.hunt! Test::Hunter::Argumented, :awesome
    expect( obj.arg ).to eq :awesome
  end

  it "implicitly spawns Class contracts" do
    expect( hunter.hunt! Test::Hunter::Implicit ).to be_a Test::Hunter::Implicit
  end

  it "feeds the same food to all immediate dependencies"

end