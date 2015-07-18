require 'spec_helper'

module Test
  module Nest
    class Service; end
    class Cache; end
    class Guard; end
  end
end

describe Scorpion::Rails::Controller, type: :controller do
  controller ActionController::Base do
    include Scorpion::Rails::Controller

    feed_on do
      service Test::Nest::Service
      cache   Test::Nest::Cache
    end

    def index
      @guard1 = scorpion.hunt Test::Nest::Guard
      @guard2 = scorpion.hunt Test::Nest::Guard
      render nothing: true
    end
  end

  context "basics" do
    before( :each ) do
      controller.class.scorpion_nest do
        hunt_for  Test::Nest::Guard   # New each spawn
        capture   Test::Nest::Service # Once per request

        share do
          capture   Test::Nest::Cache   # Once for all requests
        end
      end

      get :index
    end

    it "has a scorpion" do
      expect( subject ).to respond_to :scorpion
    end

    it "initializes non-lazy dependencies" do
      expect( subject.cache ).to be_present
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
        service = subject.scorpion.hunt Test::Nest::Service
        expect( subject.scorpion.hunt Test::Nest::Service ).to be service
        controller.render nothing: true
      end

      get :index
    end

    it "spawns a different service each request" do
      service = subject.service

      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.hunt Test::Nest::Service ).not_to be service
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for controller" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.hunt( AbstractController::Base ) ).to be subject
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for response" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.hunt( ActionDispatch::Response ) ).to be subject.response
        controller.render nothing: true
      end

      get :index
    end

    it "hunts for request" do
      allow( subject ).to receive( :index ) do
        expect( subject.scorpion.hunt( ActionDispatch::Request ).object_id ).to be subject.request.object_id
        controller.render nothing: true
      end

      get :index
    end
  end
end