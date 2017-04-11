require "spec_helper"

describe ResultsController do
  before(:each) do
    slack_message = double('slack_message').as_null_object
    allow(slack_message).to receive(:save_after_rating)
    allow(slack_message).to receive(:message)
    allow(SlackMessage).to receive(:new).and_return(slack_message)
    allow(SlackService).to receive(:notify)

    sign_in_user
  end

  describe "new" do
    it "exposes a new result" do
      game = FactoryGirl.create(:game)

      get :new, params: {game_id: game}

      expect(assigns(:result)).not_to be_nil
    end

    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :new, params: {game_id: game}

      expect(assigns(:game)).to eq(game)
    end
  end

  describe "create" do
    context "when defeated the opponent" do
      it "creates a new result with the current player as the winner" do
        game = FactoryGirl.create(:game, results: [])
        opponent = FactoryGirl.create(:player)
        current_player = FactoryGirl.create(:player, email: TEST_EMAIL)

        post :create, params: {game_id: game, relation: 'defeated', result: {
          teams: {
            "1" => { players: [opponent.id.to_s] }
          }
        }}

        result = game.reload.results.first

        expect(result).not_to be_nil

        expect(result.winners).to eq([current_player])
        expect(result.losers).to eq([opponent])
      end
    end

    context "when lost to the opponent" do
      it "creates a new result with the opponent as the winner" do
        game = FactoryGirl.create(:game, results: [])
        opponent = FactoryGirl.create(:player)
        current_player = FactoryGirl.create(:player, email: TEST_EMAIL)

        post :create, params: {game_id: game, relation: 'lost to', result: {
          teams: {
            "1" => { players: [opponent.id.to_s] }
          }
        }}

        result = game.reload.results.first

        expect(result).not_to be_nil

        expect(result.winners).to eq([opponent])
        expect(result.losers).to eq([current_player])
      end
    end

    context "when user TRIES TO HACK the current user" do
      it "ignores the injected player and use the current player anyway" do
        game = FactoryGirl.create(:game, results: [])
        opponent = FactoryGirl.create(:player)
        current_player = FactoryGirl.create(:player, email: TEST_EMAIL)

        post :create, params: {game_id: game, relation: 'lost to', result: {
          teams: {
            "0" => { players: [FactoryGirl.create(:player, name: "Others")] },
            "1" => { players: [opponent.id.to_s] }
          }
        }}

        result = game.reload.results.first

        expect(result).not_to be_nil

        expect(result.winners).to eq([opponent])
        expect(result.losers).to eq([current_player])
      end
    end

    context "when user did not select the opponent" do
      it "renders the ':new' template" do
        game = FactoryGirl.create(:game, results: [])
        opponent = FactoryGirl.create(:player)
        FactoryGirl.create(:player, email: TEST_EMAIL)

        result = post :create, params: {game_id: game, relation: 'lost to', result: {
          teams: {
            "1" => { players: [nil] }
          }
        }}

        expect(result).to render_template(:new)
      end
    end
  end

  describe "destroy" do
    context "the most recent result for each player" do
      it "destroys the result and resets the elo for each player" do
        game = FactoryGirl.create(:elo_game, results: [])
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        ResultService.create(game,
          teams: {
            "0" => { players: [player_1.id.to_s] },
            "1" => { players: [player_2.id.to_s] }
          }
        ).result

        player_1_rating = player_1.ratings.where(game_id: game.id).first
        player_2_rating = player_2.ratings.where(game_id: game.id).first

        old_rating_1 = player_1_rating.value
        old_rating_2 = player_2_rating.value

        result = ResultService.create(game,
          teams: {
            "0" => { players: [player_1.id.to_s] },
            "1" => { players: [player_2.id.to_s] }
          }
        ).result

        expect(player_1_rating.reload.value).not_to eq(old_rating_1)
        expect(player_2_rating.reload.value).not_to eq(old_rating_2)

        request.env['HTTP_REFERER'] = game_path(game)

        delete :destroy, params: {game_id: game, id: result}

        expect(response).to redirect_to(game_path(game))

        expect(player_1_rating.reload.value).to eq(old_rating_1)
        expect(player_2_rating.reload.value).to eq(old_rating_2)

        expect(player_1.reload.results.size).to eq(1)
        expect(player_2.reload.results.size).to eq(1)
      end
    end
  end
end
