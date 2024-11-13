require "spec_helper"

module Test
  module Hunter
    class Beast; end
    class Bear < Beast; end
    class Lion < Beast; end
    class Tiger < Beast; end
    class Grizly < Bear; end
    class Argumented
      def initialize(arg)
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
        zoo Test::Hunter::Zoo
      end

      def initialize(zoo = nil)
        self.zoo = zoo
      end
    end

    class City
      include Scorpion::Object

      depend_on do
        park Park
        zoo Test::Hunter::Zoo
      end

      def initialize(zoo = nil)
        self.zoo = zoo
      end
    end

    class Singleton
    end

    class Madonna < Singleton
    end

    class Cher < Singleton
    end
  end
end

describe Scorpion::Hunter do
  let(:hunter) do
    Scorpion::Hunter.new do
      capture Test::Hunter::Lion
      capture Test::Hunter::Tiger

      hunt_for Test::Hunter::Bear
      hunt_for Test::Hunter::Grizly
      hunt_for Test::Hunter::Argumented

      hunt_for Test::Hunter::Zoo

      share do
        capture Test::Hunter::Madonna
        capture Test::Hunter::Cher
      end
    end
  end

  it "spawns dependency" do
    expect(hunter.fetch(Test::Hunter::Beast)).to(be_a(Test::Hunter::Beast))
  end

  it "spawns a new instance for multiple requests" do
    first = hunter.fetch(Test::Hunter::Beast)
    expect(hunter.fetch(Test::Hunter::Beast)).not_to(be(first))
  end

  it "spawns the same instance for captured dependency" do
    first = hunter.fetch(Test::Hunter::Lion)
    expect(hunter.fetch(Test::Hunter::Lion)).to(be(first))
  end

  it "does not capture a sibling dependency" do
    first = hunter.fetch(Test::Hunter::Lion)
    expect(hunter.fetch(Test::Hunter::Tiger)).not_to(be(first))
    expect(hunter.fetch(Test::Hunter::Tiger)).to(be_a(Test::Hunter::Tiger))
  end

  it "does not share a captured sibling dependency" do
    singer = hunter.fetch(Test::Hunter::Madonna)
    expect(hunter.fetch(Test::Hunter::Cher)).not_to(be(singer))
    expect(hunter.fetch(Test::Hunter::Cher)).to(be_a(Test::Hunter::Cher))
  end

  it "does not share a captured ancestor dependency" do
    singer = hunter.fetch(Test::Hunter::Singleton)
    expect(hunter.fetch(Test::Hunter::Madonna)).not_to(be(singer))
    expect(hunter.fetch(Test::Hunter::Madonna)).to(be_a(Test::Hunter::Madonna))
  end

  it "captures derived dependency" do
    singer = hunter.fetch(Test::Hunter::Singleton)
    expect(singer).to(be_a(Test::Hunter::Cher))
  end

  it "injects nested objects" do
    zoo = hunter.fetch(Test::Hunter::Zoo)
    expect(zoo.bear).to(be_a(Test::Hunter::Bear))
  end

  it "accepts arguments that are passed to constructor" do
    obj = hunter.fetch(Test::Hunter::Argumented, :awesome)
    expect(obj.arg).to(eq(:awesome))
  end

  it "implicitly spawns Class contracts" do
    expect(hunter.fetch(Test::Hunter::Implicit)).to(be_a(Test::Hunter::Implicit))
  end

  it "initialize explicit contracts" do
    zoo = hunter.new(Test::Hunter::Zoo)
    expect(zoo).to(be_a(Test::Hunter::Zoo))
    expect(zoo.scorpion).to(eq(hunter))
  end

  it "delegates hunting definitions" do
    hunter.hunt_for(Test::Hunter::Zoo, return: :nyc)
    expect(hunter.fetch(Test::Hunter::Zoo)).to(eq(:nyc))
  end

  context "child dependencies" do
    it "passes initializer args to child dependencies" do
      zoo  = hunter.new(Test::Hunter::Zoo)
      city = hunter.fetch(Test::Hunter::City, zoo)

      expect(city.park.zoo).to(be(zoo))
    end

    it "passes self to child dependencies" do
      zoo  = hunter.new(Test::Hunter::Zoo)
      city = hunter.fetch(Test::Hunter::City, zoo)

      expect(city.park.city).to(be(city))
    end

    it "gets a new instance for the same contract on a different hunt" do
      zoo = hunter.new(Test::Hunter::Zoo)
      other_zoo = hunter.new(Test::Hunter::Zoo)

      expect(zoo).not_to(be(other_zoo))
    end
  end

  describe "#find_dependency" do
    def build_hunt(hunter)
      Scorpion::Hunt.new(hunter, Test::Hunter::Singleton, [])
    end

    it "finds a dependency" do
      expect(hunter.find_dependency(build_hunt(hunter))).to(be_a(Scorpion::Dependency))
    end

    it "finds a parent dependency" do
      expect(hunter.find_dependency(build_hunt(hunter.replicate))).to(be_a(Scorpion::Dependency))
    end

    it "finds grandparent dependency" do
      expect(hunter.find_dependency(build_hunt(hunter.replicate.replicate))).to(be_a(Scorpion::Dependency))
    end
  end

  describe "#inspect" do
    it "is helpful" do
      expect(hunter.inspect).to(match(/contracts/))
      expect(hunter.inspect).not_to(match(/0x/))
    end
  end
end
