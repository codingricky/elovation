require "spec_helper"

describe PlayersController do

  before(:each) do
    sign_in_user
  end

  describe "new" do
    it "exposes a new player" do
      get :new

      expect(assigns(:player)).not_to be_nil
    end
  end

  describe "create" do
    it "creates a player and redirects to dashboard" do
      post :create, params: {player: {name: "Drew", email: "drew@example.com"}}

      player = Player.where(name: "Drew", email: "drew@example.com").first

      expect(player).not_to be_nil
      expect(response).to redirect_to(dashboard_path)
    end

    it "renders new given invalid params" do
      FactoryGirl.create(:player, name: "Drew")

      post :create, params: {player: {name: "Drew"}}

      expect(response).to render_template(:new)
    end

    it "protects against mass assignment" do
      Timecop.freeze(Time.now) do
        post :create, params: {player: {created_at: 3.days.ago, name: "Drew"}}

        player = Player.where(name: "Drew").first
        expect(player.created_at).to be > 3.days.ago
      end
    end
  end

  describe "destroy" do
    it "deletes a player with no results" do
      player = FactoryGirl.create(:player)

      delete :destroy, params: {id: player}

      expect(response).to redirect_to(dashboard_path)
      expect(Player.find_by_id(player.id)).to be_nil
    end

    it "doesn't allow deleting a player with results" do
      result = FactoryGirl.create(:result)
      player = result.players.first

      delete :destroy, params: {id: player}

      expect(response).to redirect_to(dashboard_path)
      expect(Player.find_by_id(player.id)).to eq(player)
    end
  end

  describe "edit" do
    it "exposes the player for editing" do
      player = FactoryGirl.create(:player)

      get :edit, params: {id: player}

      expect(assigns(:player)).to eq(player)
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the player show page" do
        player = FactoryGirl.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        expect(response).to redirect_to(player_path(player))
      end

      it "updates the player with the provided attributes" do
        player = FactoryGirl.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        expect(player.reload.name).to eq("Second name")
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          player = FactoryGirl.create(:player, name: "First name")

          put :update, params: {id: player, player: {created_at: 3.days.ago}}

          expect(player.reload.created_at).to be > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        player = FactoryGirl.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: nil}}

        expect(response).to render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the player" do
      player = FactoryGirl.create(:player)

      get :show, params: {id: player}

      expect(assigns(:player)).to eq(player)
    end
  end
end
