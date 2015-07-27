require 'spec_helper'

module Test
  module ModuleDependency
    module Example; end
  end
end
describe Scorpion::Dependency::ModuleDependency do
  let( :scorpion ){ double }
  let( :dependency )    { Scorpion::Dependency::ModuleDependency.new( Test::ModuleDependency::Example ) }

  it "returns the module itself" do
    expect( dependency.fetch( scorpion ) ).to be Test::ModuleDependency::Example
  end

end