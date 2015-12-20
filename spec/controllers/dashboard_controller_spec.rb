require "spec_helper"

describe DashboardController do
  describe "show" do
    it "displays all players and games" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      get :show

      assigns(:users).should == [player]
      assigns(:games).should == [game]
    end
  end
end
