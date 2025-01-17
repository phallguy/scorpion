require "spec_helper"

module Test
  module BuilderDependency
    class ClassDelegate
      def call(_hunt, *_args)
        Test
      end
    end

    module ModDelegate
      module_function

      def call(_hunt, *_args)
        Test
      end
    end
  end
end

describe Scorpion::Dependency::BuilderDependency do
  let(:scorpion) { double }
  let(:hunt) { Scorpion::Hunt.new(scorpion, String, nil) }

  it "supports class hunting delegates" do
    dependency = Scorpion::Dependency::BuilderDependency.new(String, Test::BuilderDependency::ClassDelegate.new)
    expect(dependency.fetch(hunt)).to(be(Test))
  end

  it "supports module hunting delegates" do
    dependency = Scorpion::Dependency::BuilderDependency.new(String, Test::BuilderDependency::ModDelegate)
    expect(dependency.fetch(hunt)).to(be(Test))
  end

  it "supports block hunting delegates" do
    dependency = Scorpion::Dependency::BuilderDependency.new(String) do
      Test
    end
    expect(dependency.fetch(hunt)).to(be(Test))
  end
end
