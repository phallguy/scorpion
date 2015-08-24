require 'spec_helper'


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
  
  let( :scorpion ){ double Scorpion }
  let( :hunt ){ Scorpion::Hunt.new scorpion, String, nil }

  describe "#fetch_by_traits" do
    it "changes context" do
      expect( scorpion ).to receive( :execute ) do |hunt|
        expect( hunt.contract ).to eq Regexp
      end

      hunt.fetch_by_traits Regexp, nil
    end

    it "restores context" do
      expect( scorpion ).to receive( :execute )

      hunt.fetch_by_traits Numeric, nil
      expect( hunt.contract ).to eq String
    end

    it "finds matching argument in parent" do
      hunt.dependencies[:label] = "Hello"

      expect( hunt.fetch String ).to eq "Hello"
    end

    it "finds matching argument in grandparent" do
      hunt = Scorpion::Hunt.new scorpion, String, nil, label: "Hello"
      hunt.send :push, Regexp, nil, [], {}, nil

      expect( scorpion ).to receive( :execute ) do |hunt|
        next if hunt.contract == String

        expect( hunt.fetch String ).to eq "Hello"
      end.at_least(:once)

      hunt.fetch Numeric
    end
  end

  describe "#inject" do
    let( :target )  do
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
  end

end