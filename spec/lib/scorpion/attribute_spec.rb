require 'spec_helper'

describe Scorpion::Attribute do
  it "responds to trait? methods" do
    attr = Scorpion::Attribute.new :name, :contract, :formatted
    expect( attr ).to be_formatted
  end
end