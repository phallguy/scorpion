require "spec_helper"

module Test
  module Object
    class UserService; end
    class Logger; end
    class BackLogger; end
    class ColorLogger; end

    class Mamal
      include Scorpion::Object

      def initialize( family, parent = nil, options = {}, &block )
        @family    = family
        @parent    = parent
        @options   = inject_from! options


        yield if block_given?
      end

      depend_on do
        user_service Test::Object::UserService
        logger       Test::Object::Logger
        manager      Test::Object::Logger, public: true
        executive_manager Test::Object::Logger, private: true
      end

      attr_accessor :family
      attr_accessor :parent
      attr_accessor :options
    end

    class Mouse < Mamal

      depend_on do
        cheese  Test::Object::Logger
        logger  Test::Object::BackLogger
      end

      def initialize( **options )
        super "mouse", nil, options
      end
    end

    class Bear < Mamal
      depend_on do
        logger Test::Object::ColorLogger
      end
    end

  end
end

describe Scorpion::Object do

  let( :scorpion ) { double Scorpion }
  let( :hunt )    { double Scorpion::Hunt }

  before( :each ) do
    allow( scorpion ).to receive( :prepare )

    allow( hunt ).to receive( :inject )
    allow( hunt ).to receive( :scorpion ).and_return scorpion
  end

  it "stings scopes" do
    scope = double

    expect( scope ).to receive( :with_scorpion ).with( scorpion )

    Test::Object::Mouse.spawn( hunt ).scorpion( scope )
  end

  describe ".spawn" do

    it "can spawn" do
      mamal = Test::Object::Mamal.spawn hunt, "mouse", "rodent", name: "name"
      expect( mamal ).to be_a Test::Object::Mamal
    end

    it "calls inject" do
      expect( hunt ).to receive( :inject )
      Test::Object::Mouse.spawn hunt
    end

    it "can inherit" do
      mouse = Test::Object::Mouse.spawn hunt, name: "name"
      expect( mouse.family ).to eq "mouse"
      expect( mouse.options ).to include name: "name"
    end

    it "yields to constructor" do
      expect do |b|
        Test::Object::Mouse.spawn hunt, name: "name", &b
      end.to yield_control
    end

  end

  describe "accessors" do
    let( :object ) do
      Test::Object::Mamal.spawn hunt, "harry", "jim", name: "name", manager: double
    end

    subject { object }

    it "defines accessors" do
      expect( object ).to     respond_to :user_service
      expect( object ).not_to respond_to :user_service=
    end

    it "supports private reader" do
      expect( object.respond_to?(:executive_manager, false) ).to be_falsy
      expect( object.respond_to?(:executive_manager, true) ).to be_truthy
    end

    it "supports public writer" do
      expect( object.respond_to?(:manager=, false) ).to be_truthy
    end

    describe "#attr_dependency" do
      it "defines attributes" do
        klass = Class.new do
          include Scorpion::Object

          attr_dependency :logger, Test::Object::Logger
        end

        expect( klass.new ).to respond_to :logger
      end
    end

    describe "inheritance" do
      let( :object ) do
        Test::Object::Mouse.spawn hunt
      end

      it "inherits attributes" do
        expect( object.injected_attributes[:user_service].contract ).to be Test::Object::UserService
      end

      it "overrides attributes" do
        expect( object.injected_attributes[:logger].contract ).to be Test::Object::BackLogger
      end

      it "doesn't effect other classes" do
        expect( Test::Object::Bear.spawn( hunt, "Yogi" ).injected_attributes[:logger].contract ).to be Test::Object::ColorLogger # rubocop:disable Metrics/LineLength
      end

    end

  end

  describe "feasting" do
    let( :logger )  { Test::Object::Logger.new }
    let( :options ) { { manager: logger, color: :red } }
    let( :object )    { Test::Object::Mouse.new name: "mighty" }


    describe "#inject_from" do
      it "assigns attributes" do
        object.send :inject_from, options
        expect( object.manager ).to be logger
      end

      it "doesn't overwrite" do
        object.manager = Test::Object::Logger.new
        object.send :inject_from, options
        expect( object.manager ).not_to be logger
      end

      it "overwrites when asked" do
        object.manager = Test::Object::Logger.new
        object.send :inject_from, options, true
        expect( object.manager ).to be logger
      end
    end

    describe "inject_from!" do
      it "assigns attributes" do
        object.send :inject_from!, options
        expect( object.manager ).to be logger
      end

      it "doesn't overwrite" do
        object.manager = Test::Object::Logger.new
        object.send :inject_from!, options
        expect( object.manager ).not_to be logger
      end

      it "overwrites when asked" do
        object.manager = Test::Object::Logger.new
        object.send :inject_from!, options, true
        expect( object.manager ).to be logger
      end

      it "removes injected attributes" do
        expect( options ).to have_key :manager
        object.send :inject_from!, options
        expect( options ).not_to have_key :manager
      end

      it "removes injected attribute even if already set" do
        expect( options ).to have_key :manager
        object.manager = Test::Object::Logger.new
        object.send :inject_from!, options
        expect( options ).not_to have_key :manager
      end

      it "doesn't remove other options" do
        object.send :inject_from!, options
        expect( options ).to have_key :color
      end

    end
  end

end
