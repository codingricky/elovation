require "spec_helper"

describe Team do

  describe "validations" do
    context "base validations" do
      it "requires a rank" do
        team = Team.new(rank: nil)

        expect(team).not_to be_valid
        expect(team.errors[:rank]).to eq(["can't be blank"])
      end
    end
  end
end
