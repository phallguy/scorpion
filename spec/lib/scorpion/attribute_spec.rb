require "spec_helper"

module Test
  class Attr; end
end


describe Scorpion::Attribute do
  it "resolves contract strings to constants" do
    attr = Scorpion::Attribute.new :name, "Test::Attr"
    expect( attr.contract ).to be Test::Attr
  end
end
