require 'spec_helper'

module Test
  module King
    class UserService; end
    class Logger; end
    class BackLogger; end
    class ColorLogger; end

    class Mamal
      include Scorpion::King

      def initialize( family, parent = nil, options={}, &block )
        @family    = family
        @parent    = parent
        @options   = feast_on! options


        yield if block_given?
      end

      feed_on do
        user_service Test::King::UserService
        logger       Test::King::Logger
        manager      Test::King::Logger, public: true
        executive_manager Test::King::Logger, private: true
      end

      attr_accessor :family
      attr_accessor :parent
      attr_accessor :options
    end

    class Mouse < Mamal

      feed_on do
        cheese  Test::King::Logger
        logger  Test::King::BackLogger
      end
      def initialize( options = {} )
        super 'mouse', nil, options
      end
    end

    class Bear < Mamal
      feed_on do
        logger Test::King::ColorLogger
      end
    end

  end
end

describe Scorpion::King do

  let( :scorpion ){ double Scorpion }

  before( :each ) do
    allow( scorpion ).to receive( :feed )
  end

  describe ".spawn" do

    it "can spawn" do
      mamal = Test::King::Mamal.spawn scorpion, 'mouse', 'rodent', name: 'name'
      expect( mamal ).to be_a Test::King::Mamal
    end

    it "calls feed" do
      expect( scorpion ).to receive( :feed )
      Test::King::Mouse.spawn scorpion
    end

    it "can inherit" do
      mouse = Test::King::Mouse.spawn scorpion, name: 'name'
      expect( mouse.family ).to eq 'mouse'
      expect( mouse.options ).to include name: 'name'
    end

    it "yields to constructor" do
      expect do |b|
        Test::King::Mouse.spawn scorpion, name: 'name', &b
      end.to yield_control
    end

    it "invokes on_fed" do
      expect_any_instance_of( Test::King::Mouse ).to receive( :on_fed )
      Test::King::Mouse.spawn scorpion
    end
  end

  describe "accessors" do
    let( :king ) do
      Test::King::Mamal.spawn scorpion, 'harry', 'jim', name: 'name', manager: double
    end

    subject{ king }

    it "defines accessors" do
      expect( king ).to     respond_to :user_service
      expect( king ).not_to respond_to :user_service=
    end

    it "supports private reader" do
      expect( king.respond_to? :executive_manager, false ).to be_falsy
      expect( king.respond_to? :executive_manager, true ).to be_truthy
    end

    it "supports public writer" do
      expect( king.respond_to? :manager=, false ).to be_truthy
    end

    describe  "inheritance" do
      let( :king ) do
        Test::King::Mouse.spawn scorpion
      end

      it "inherits attributes" do
        expect( king.injected_attributes[:user_service].contract ).to be Test::King::UserService
      end

      it "overrides attributes" do
        expect( king.injected_attributes[:logger].contract ).to be Test::King::BackLogger
      end

      it "doesn't effect other classes" do
        expect( Test::King::Bear.spawn( scorpion, 'Yogi' ).injected_attributes[:logger].contract ).to be Test::King::ColorLogger
      end

    end

  end

  describe "feasting" do
    let( :logger )  { Test::King::Logger.new }
    let( :options ) { { manager: logger, color: :red } }
    let( :king )    { Test::King::Mouse.new name: 'mighty' }


    describe "#feast_on" do
      it "assigns attributes" do
        king.send :feast_on, options
        expect( king.manager ).to be logger
      end

      it "doesn't overwrite" do
        king.manager = Test::King::Logger.new
        king.send :feast_on, options
        expect( king.manager ).not_to be logger
      end

      it "overwrites when asked" do
        king.manager = Test::King::Logger.new
        king.send :feast_on, options, true
        expect( king.manager ).to be logger
      end
    end

    describe "feast_on!" do
      it "assigns attributes" do
        king.send :feast_on!, options
        expect( king.manager ).to be logger
      end

      it "doesn't overwrite" do
        king.manager = Test::King::Logger.new
        king.send :feast_on!, options
        expect( king.manager ).not_to be logger
      end

      it "overwrites when asked" do
        king.manager = Test::King::Logger.new
        king.send :feast_on!, options, true
        expect( king.manager ).to be logger
      end

      it "removes injected attributes" do
        expect( options ).to have_key :manager
        king.send :feast_on!, options
        expect( options ).not_to have_key :manager
      end

      it "removes injected attribute even if already set" do
        expect( options ).to have_key :manager
        king.manager = Test::King::Logger.new
        king.send :feast_on!, options
        expect( options ).not_to have_key :manager
      end

      it "doesn't remove other options" do
        king.send :feast_on!, options
        expect( options ).to have_key :color
      end

    end
  end

end