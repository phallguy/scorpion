require 'spec_helper'
require 'scorpion/rspec'
load 'scorpion/rspec/helper.rb'

Scorpion::Rspec.prepare do
  hunt_for Numeric, return: 42
end

module ScorpionRspecHelperSpec
  class Food
    include Scorpion::Object
  end
end

describe Scorpion::Rspec::Helper do
  include Scorpion::Rspec::Helper

  scorpion do
    hunt_for String, return: "Shazam!"
  end

  it "provides a scorpion" do
    expect( scorpion ).not_to be_nil
  end

  it "is configurable" do
    expect( scorpion.fetch String ).to eq "Shazam!"
  end

  it "inherits global config" do
    expect( scorpion.fetch Numeric ).to eq 42
  end

  context "hunting" do
    hunt( :number, Numeric, 5 )
    hunt( :string, String ) { "hello" }
    hunt( :double, Regexp )
    capture( :food, ScorpionRspecHelperSpec::Food )

    specify{ expect( scorpion.fetch Numeric ).to eq 5 }
    specify{ expect( scorpion.fetch String  ).to eq "hello" }
    specify{ expect( scorpion.fetch Regexp  ).to be_a RSpec::Mocks::TestDouble }
    specify{ expect( scorpion.fetch ScorpionRspecHelperSpec::Food ).to be_a ScorpionRspecHelperSpec::Food }
  end

  context "child context" do
    it "inherits" do
      expect( scorpion.fetch String ).to eq "Shazam!"
    end

    context "overrides" do

      scorpion do
        hunt_for String, return: "KaPow"
      end

      it "overrides" do
        expect( scorpion.fetch String ).to eq "KaPow"
      end
    end
  end
end