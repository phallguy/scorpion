require 'spec_helper'

module Test
  module Job
    class Compass
      def directions; end
    end

    class Journey < ActiveJob::Base
      include Scorpion::Rails::Job

      depend_on do
        compass Test::Job::Compass
      end

      def perform
        compass.directions
      end
    end
  end
end

describe Scorpion::Rails::Job do
  it "perform has been feed" do
    compass = Test::Job::Compass.new

    Test::Job::Journey.scorpion_nest do |hunter|
      hunter.hunt_for Test::Job::Compass, return: compass
    end

    expect( compass ).to receive( :directions )
    Test::Job::Journey.perform_now
  end
end