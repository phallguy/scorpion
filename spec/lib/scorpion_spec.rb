require 'spec_helper'

module Test
  module Scorpion
    class Logger; end

    class Target
      include ::Scorpion::King

      feed_on do
        logger Logger, public: true
        sailor Logger, public: true, lazy: true
      end
    end
  end
end

describe Scorpion do
  let( :scorpion ){ Scorpion::Hunter.new }
  let( :target )  do
    Test::Scorpion::Target.new.tap do |target|
      target.instance_variable_set :@scorpion, scorpion
    end
  end

  describe "#feed" do
    it "injects attributes" do
      scorpion.feed target

      expect( target.logger? ).to be_truthy
      expect( target.logger  ).to be_a Test::Scorpion::Logger
    end

    it "does not overwrite existing attributes" do
      logger = Test::Scorpion::Logger.new
      target.logger = logger
      scorpion.feed target

      expect( target.logger ).to be logger
    end

    it "does not fetch lazy attributes" do
      scorpion.feed target
      expect( target.sailor? ).to be_falsy
    end
  end
end