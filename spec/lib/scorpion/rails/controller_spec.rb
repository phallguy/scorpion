require "spec_helper"

module Test
  module Nest
    class Service; end
    class Cache; end
    class Guard; end
    class Provided; end
  end
end

describe Scorpion::Rails::Controller, type: :controller do
  controller ActionController::Base do

    depend_on do
      service Test::Nest::Service
      cache   Test::Nest::Cache
    end

    hunt_for Test::Nest::Provided do |scorpion|
      scorpion.new Test::Nest::Provided
    end

    hunt_for String do |_scorpion|
      instance_value
    end

    def index
      @guard1 = scorpion.fetch Test::Nest::Guard
      @guard2 = scorpion.fetch Test::Nest::Guard
      render nothing: true
    end

    private

      def instance_value
        "Snappy"
      end
  end

  context "basics" do
    before( :each ) do
      controller.class.scorpion_nest do
        hunt_for  Test::Nest::Guard   # New each spawn
        capture   Test::Nest::Service # Once per request

        share do
          capture Test::Nest::Cache # Once for all requests
        end
      end

      get :index
    end

    it "has a scorpion" do
      expect( subject ).to respond_to :scorpion
    end

    it "retrieves scorpion from `env`" do
      expect( subject ).to receive( :scorpion ).at_least( :once ).and_wrap_original do |method, *args|
        scorpion = method.call( *args )
        expect( scorpion ).to be subject.request.env[ Scorpion::Rails::Controller::ENV_KEY ]

        scorpion
      end

      get :index
    end

    it "stores the scorpion in `env`" do
      expect( subject ).to receive( :assign_scorpion ).and_wrap_original do |method, *args|
        expect( subject.request.env ).to receive( :[]= )
          .with( Scorpion::Rails::Controller::ENV_KEY, kind_of( Scorpion ) )
          .at_least( :once )
          .and_call_original

        method.call( *args )
      end

      get :index
    end

    it "prepares a scorpion outside of a request when accessed" do
      expect( subject.env[Scorpion::Rails::Controller::ENV_KEY] ).to be_nil
      expect( subject.scorpion ).not_to be_nil
    end

    it "initializes non-lazy dependencies" do
      expect( subject.cache ).to be_present
    end

    it "hunts for instance provided dependencies" do
      expect( subject.scorpion.fetch( Test::Nest::Provided ) ).to be_a Test::Nest::Provided
    end

    it "instance dependencies can access instance methods" do
      expect( subject.scorpion.fetch( String ) ).to eq "Snappy"
    end

    it "spawns multiple guards" do
      expect( assigns( :guard1 ) ).to     be_present
      expect( assigns( :guard2 ) ).to     be_present
      expect( assigns( :guard1 ) ).not_to eq assigns( :guard2 )
    end

    it "spawns a single cache for all requests" do
      original_cache = subject.cache
      get :index

      expect( original_cache ).to be_present
      expect( subject.cache ).to be original_cache
    end

    it "spawns the same service during the same request" do
      allow( subject ).to receive( :index ) do
        service = subject.scorpion.fetch Test::Nest::Service
        expect( subject.scorpion.fetch(Test::Nest::Service) ).to be service
        controller.render nothing: true
      end

      get :index
    end

    it "spawns a different service each request" do
      service = subject.service

      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.fetch(Test::Nest::Service) ).not_to be service
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for controller" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.fetch( AbstractController::Base ) ).to be subject
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for response" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.fetch( ActionDispatch::Response ) ).to be subject.response
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for request" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.fetch( ActionDispatch::Request ).object_id ).to be subject.request.object_id
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for rack env" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.fetch( Scorpion::Rack::Env ) ).to be_present
        controller.render nothing: true
      end

      get :index
    end

    it "scopes relations" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion( Todo ).all.scorpion ).to be subject.scorpion
        controller.render nothing: true
      end

      get :index
    end
  end
end
