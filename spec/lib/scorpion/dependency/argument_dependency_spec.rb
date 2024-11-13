require "spec_helper"

describe Scorpion::Dependency::ArgumentDependency do
  let(:dependency) { Scorpion::Dependency::ArgumentDependency.new(arg) }
  let(:arg) { "Hello" }

  it "matches the same type" do
    expect(dependency.satisfies?(String)).to(be_truthy)
  end

  it "doesn't match different types" do
    expect(dependency.satisfies?(Regexp)).to(be_falsy)
  end
end
