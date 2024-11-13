require "spec_helper"

describe Scorpion::UnsuccessfulHunt do
  it "formats the default message" do
    expect(Scorpion::UnsuccessfulHunt.new(:attr).message).to(match(/builder/))
  end
end