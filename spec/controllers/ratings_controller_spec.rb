require "spec_helper"

describe RatingsController do
  before(:each) do
    sign_in_user
  end

  describe "index" do
    it "renders ratins for the given game" do
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, game: game)

      get :index, game_id: game

      expect(assigns(:game)).to eq(game)
      expect(response).to render_template(:index)
    end
  end
end
