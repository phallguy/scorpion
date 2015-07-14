require 'spec_helper'

module Test
  module Nest
    class UserService; end
    class Logger; end

    class Mamal
      include Scorpion::King

      def initialize( family, parent = nil, options={} )
        @family    = family
        @parent    = parent
        @options   = options
      end

      feed_on do
        user_service Test::Nest::UserService
        logger Test::Nest::Logger
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

  let( :scorpion ) do
    Scorpion::Scorpions::Simple.new do
    end
  end


  describe "constructor" do

    it "accepts injections" do

    end

    it "resolves unmet injections" do

    end

    it "can spawn", :focus do
      mamal = scorpion.spawn Test::Nest::Mamal, 'mouse', 'rodent', name: 'name'
      expect( mamal ).to be_a Test::Nest::Mamal
    end

    it "can inherit" do
      mouse = scorpion.spawn Test::Nest::Mouse, name: 'name'
      expect( mouse.family ).to eq 'mouse'
      expect( mouse.options ).to include name: 'name'
    end
  end

  describe "accessors" do
    let( :prey ) do
      sorpion.spawn Test::Nest::Mamal, 'harry', 'jim', name: 'name', manager: double
    end

    subject{ prey }

    it "has a user_service attr" do
      expect( prey ).to respond_to :user_service
    end

    it "has a logger attr" do
      expect( prey ).to respond_to :logger
    end

    it "strips injected attributes" do
      expect( prey.options ).not_to key :manager
    end

  end

  describe "#extract_injections" do
    class NestInjections
      include Scorpion::King
    end

    let( :args ) { ['name', :apples, a: 'a', in: 'jected'] }

    before( :each ) do
      allow( NestInjections ).to receive( :injected_attributes ).and_return [Scorpion::Attribute.new( false, :in, nil, nil )]
    end

    it "removes injected" do
      real, _ = NestInjections.send :extract_injections, args

      expect( real ).to eq( [ 'name', :apples, { a: 'a' } ] )
    end

    it "extract injected" do
      _, injections = NestInjections.send :extract_injections, args

      expect( injections ).to eq( { in: 'jected' } )
    end

    it "doesn't dup if no changes needed" do
      ops     = { a: 'a' }
      args, _ = NestInjections.send :extract_injections, [ 'name', ops ]

      expect( args.last ).to be ops
    end
  end

end