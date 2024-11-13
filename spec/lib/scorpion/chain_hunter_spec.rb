require "spec_helper"

describe Scorpion::ChainHunter do
  describe "#replicate" do
    it "replicates all chained scorpions" do
      scorpion = double(Scorpion::Hunter)
      chained  = Scorpion::ChainHunter.new(scorpion)

      expect(scorpion).to(receive(:replicate))
      chained.replicate
    end

    it "can execute after replication" do
      scorpion   = double(Scorpion::Hunter)
      chained    = Scorpion::ChainHunter.new(scorpion)

      allow(scorpion).to(receive(:replicate).and_return(scorpion))
      expect(scorpion).to(receive(:execute))

      replicated = chained.replicate
      replicated.execute(double(Scorpion::Hunt))
    end
  end
end