require "spec_helper"


module Test
  module Hunt
    class Logger; end

    class Target
      include ::Scorpion::Object

      depend_on do
        logger Logger, public: true
        sailor Logger, public: true, lazy: true
      end
    end

  end
end

describe Scorpion::Hunt do

  let( :scorpion ) { double Scorpion }
  let( :hunt ) { Scorpion::Hunt.new scorpion, String, nil }

  describe "#fetch" do
    it "changes context" do
      expect( scorpion ).to receive( :execute ) do |hunt|
        expect( hunt.contract ).to eq Regexp
      end

      hunt.fetch Regexp, nil
    end

    it "restores context" do
      expect( scorpion ).to receive( :execute )

      hunt.fetch Numeric, nil
      expect( hunt.contract ).to eq String
    end
  end

  describe "#inject" do
    let( :target ) do
      Test::Hunt::Target.new
    end

    before( :each ) do
      allow( scorpion ).to receive( :execute ) do |hunt|
        Test::Hunt::Logger.new if hunt.contract == Test::Hunt::Logger
      end
    end

    it "injects attributes" do
      hunt.inject target

      expect( target.logger? ).to be_truthy
      expect( target.logger  ).to be_a Test::Hunt::Logger
    end

    it "does not overwrite existing attributes" do
      logger = Test::Hunt::Logger.new
      target.logger = logger
      hunt.inject target

      expect( target.logger ).to be logger
    end

    it "does not fetch lazy attributes" do
      hunt.inject target
      expect( target.sailor? ).to be_falsy
    end

    it "uses the same hunt when lazy fetching" do
      hunt.inject target

      expect( hunt ).to receive( :fetch ).with( Test::Hunt::Logger )
      target.sailor
    end

    it "invokes on_injected" do
      expect( target ).to receive( :on_injected )
      hunt.inject target
    end

  end

end
