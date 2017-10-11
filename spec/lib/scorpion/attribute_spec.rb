require "spec_helper"

module Test
  class Attr; end
end


describe Scorpion::Attribute do
  it "responds to trait? methods" do
    attr = Scorpion::Attribute.new :name, :contract, :formatted
    expect( attr ).to be_formatted
  end

  it "resolves contract strings to constants" do
    attr = Scorpion::Attribute.new :name, "Test::Attr"
    expect( attr.contract ).to be Test::Attr
  end
end