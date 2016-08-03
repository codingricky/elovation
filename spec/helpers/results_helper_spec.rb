require "spec_helper"

describe ResultsHelper do
  # worth mentioning: `let` is lazy evaluated, `let!` executes immeditately
  # using `let` fails the second test because -
  # `player_options` uses `Player.order(...).all` and p2 wasn't called before that
  let!(:p1) { FactoryGirl.create(:player, name: "First") }
  let!(:p2) { FactoryGirl.create(:player, name: "Second") }

  describe "player_options" do
    context "when index is 0" do
      it "returns an associative array of the CURRENT player's name and id" do
        expect(helper.player_options(0, p1)).to eq([[p1.name, p1.id]])
      end
    end
    context "when index is greater than 0" do
      it "returns an associative array of OTHER players' names and ids" do
        expect(helper.player_options(1, p1)).to eq([[p2.name, p2.id]])
      end
    end
  end

  describe "player_dropdown_tag_opts" do
    context "when index is 0" do
      it "returns an option with the 'selected' key" do
        opts = helper.player_dropdown_tag_opts(0, p1)
        expect(opts).to eq({selected: p1.id})
      end
    end
    context "when index is greater than 0" do
      it "returns an option with the 'include_blank' key" do
        opts = helper.player_dropdown_tag_opts(1, p1)
        expect(opts).to eq({include_blank: ''})
      end
    end
  end

  describe "player_dropdown_html_opts" do
    context "when index is 0" do
      it "current player gets selected and not editable" do
        opts = helper.player_dropdown_html_opts(0, p1)
        expect(opts[:selected]).to eq(p1.id)
        expect(opts[:disabled]).to be true
        expect(opts['data-placeholder']).to be_nil
      end
    end
    context "when index is greater than 0" do
      it "no player gets selected and the user can choose one" do
        opts = helper.player_dropdown_html_opts(1, p1)
        expect(opts[:selected]).to be_nil
        expect(opts[:disabled]).to be_nil
        expect(opts['data-placeholder']).to eql("Select Opponent: ")
      end
    end
  end

  describe "relation_options" do
    it "contains 'defeated' and 'lost to' options" do
      expect(helper.relation_options).to eq(['defeated', 'lost to'])
    end
  end
end
