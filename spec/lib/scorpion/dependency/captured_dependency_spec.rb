require "spec_helper"

describe Scorpion::Dependency::CapturedDependency do
  describe "#replicate" do
    it "does not hold reference to previously captured instance" do
      spec     = double(Scorpion::Dependency::ClassDependency)
      instance = double
      allow(spec).to(receive(:fetch).and_return(instance))

      captured = Scorpion::Dependency::CapturedDependency.new(spec)
      captured.fetch(nil) # Force instance to be resolved

      expect(captured.replicate.instance).to(be_nil)
    end
  end
end