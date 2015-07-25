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
      include Scorpion::Object

      depend_on do
        bear Bear
      end
    end

    class City; end

    class Park
      include Scorpion::Object

      depend_on do
        city City
      end

      initialize( zoo: Test::Hunter::Zoo )
    end

    class City
      include Scorpion::Object

      depend_on do
        park Park
      end

      initialize( zoo: Test::Hunter::Zoo )
    end

  end
end

describe Scorpion::Hunter do

  let( :hunter ) do
    Scorpion::Hunter.new do
      capture Test::Hunter::Lion, :tame

      hunt_for Test::Hunter::Bear
      hunt_for Test::Hunter::Lion, :male
      hunt_for Test::Hunter::Grizly, :female
      hunt_for Test::Hunter::Argumented

      hunt_for Test::Hunter::Zoo
    end
  end

  it "spawns dependency" do
    expect( hunter.fetch Test::Hunter::Beast ).to be_a Test::Hunter::Beast
  end

  it "spawns a new instance for multiple requests" do
    first = hunter.fetch Test::Hunter::Beast
    expect( hunter.fetch Test::Hunter::Beast ).not_to be first
  end

  it "spawns the same instance for captured dependency" do
    first = hunter.fetch_by_traits Test::Hunter::Beast, :tame
    expect( hunter.fetch_by_traits Test::Hunter::Beast, :tame ).to be first
  end

  it "injects nested objects" do
    zoo = hunter.fetch Test::Hunter::Zoo
    expect( zoo.bear ).to be_a Test::Hunter::Bear
  end

  it "accepts arguments that are passed to constructor" do
    obj = hunter.fetch Test::Hunter::Argumented, :awesome
    expect( obj.arg ).to eq :awesome
  end

  it "implicitly spawns Class contracts" do
    expect( hunter.fetch Test::Hunter::Implicit ).to be_a Test::Hunter::Implicit
  end

  it "implicitly spawns Class contracts with empty traits" do
    expect( hunter.fetch_by_traits Test::Hunter::Implicit, [] ).to be_a Test::Hunter::Implicit
  end

  context "child dependencies" do
    it "passes initializer args to child dependencies" do
      zoo  = Test::Hunter::Zoo.new
      city = hunter.fetch Test::Hunter::City, zoo

      expect( city.park.zoo ).to be zoo
    end

    it "passes self to child dependencies" do
      zoo  = Test::Hunter::Zoo.new
      city = hunter.fetch Test::Hunter::City, zoo

      expect( city.park.city ).to be city
    end
  end

end