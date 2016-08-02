require "spec_helper"

describe DashboardController do
  describe "show" do
    it "displays all players and games" do
      sign_in_user

      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      get :show

      expect(assigns(:players)).to eq([player])
      expect(assigns(:games)).to eq([game])
    end
  end
end
