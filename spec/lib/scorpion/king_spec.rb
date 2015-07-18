require 'spec_helper'

module Test
  module King
    class UserService; end
    class Logger; end

    class Mamal
      include Scorpion::King

      def initialize( family, parent = nil, options={}, &block )
        @family    = family
        @parent    = parent
        @options   = options

        yield if block_given?
      end

      feed_on do
        user_service Test::King::UserService
        logger       Test::King::Logger
        manager      Test::King::Logger
      end

      attr_accessor :family
      attr_accessor :parent
      attr_accessor :options
    end

    class Mouse < Mamal
      def initialize( options = {} )
        super 'mouse', nil, options
      end
    end

  end
end

describe Scorpion::King do

  let( :scorpion ){ double Scorpion }

  before( :each ) do
    allow( scorpion ).to receive( :feed! )
  end

  describe ".spawn" do

    it "can spawn" do
      mamal = Test::King::Mamal.spawn scorpion, 'mouse', 'rodent', name: 'name'
      expect( mamal ).to be_a Test::King::Mamal
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
    let( :prey ) do
      Test::King::Mamal.spawn scorpion, 'harry', 'jim', name: 'name', manager: double
    end

    subject{ prey }

    it "defines accessors" do
      expect( prey ).to     respond_to :user_service
      expect( prey ).not_to respond_to :user_service=
    end

    xit "supports private reader"
    xit "supports public writer"

  end

  describe  "inheritance" do
    xit "can override feed_on"
  end

end