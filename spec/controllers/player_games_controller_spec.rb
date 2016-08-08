require "spec_helper"

describe PlayerGamesController do
  before(:each) do
    sign_in_user
  end

  describe "show" do
    it "renders successfully with the player and the game" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      get :show, player_id: player, id: game
      expect(response).to be_success

      expect(assigns(:game)).to eq(game)
      expect(assigns(:player)).to eq(player)
    end
  end
end
