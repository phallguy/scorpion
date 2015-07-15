require 'spec_helper'

module Test
  module ModulePrey
    module Example; end
  end
end
describe Scorpion::Prey::ModulePrey do
  let( :scorpion ){ double }
  let( :prey )    { Scorpion::Prey::ModulePrey.new( Test::ModulePrey::Example ) }

  it "returns the module itself" do
    expect( prey.fetch( scorpion ) ).to be Test::ModulePrey::Example
  end

end