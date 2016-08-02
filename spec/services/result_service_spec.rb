require "spec_helper"

describe ResultService do
  describe "create" do
    it "builds a result given a game and params" do
      game = FactoryGirl.create(:elo_game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player1.id.to_s] },
          "1" => { players: [player2.id.to_s] }
        }
      )

      expect(response).to be_success
      result = response.result
      expect(result.winners).to eq([player1])
      expect(result.losers).to eq([player2])
      expect(result.game).to eq(game)
    end

    it "returns success as false if there are validation errors" do
      game = FactoryGirl.create(:elo_game)
      player = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player.id.to_s] },
          "1" => { players: [player.id.to_s] }
        }
      )

      expect(response).not_to be_success
    end

    it "handles nil winner or loser" do
      game = FactoryGirl.create(:elo_game)
      player = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player.id.to_s] },
          "1" => { players: [] }
        }
      )

      expect(response).not_to be_success

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [nil] },
          "1" => { players: [player.id.to_s] }
        }
      )

      expect(response).not_to be_success
    end

    it "is successful on trailing empty teams" do
      game = FactoryGirl.create(:elo_game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player1.id.to_s] },
          "1" => { players: [player2.id.to_s] },
          "2" => { players: [] }
        }
      )

      expect(response).to be_success
      result = response.result
      expect(result.winners).to eq([player1])
      expect(result.losers).to eq([player2])
      expect(result.game).to eq(game)
    end

    it "fails on skipped teams" do
      game = FactoryGirl.create(:elo_game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player1.id.to_s] },
          "1" => { players: [""] },
          "2" => { players: [player2.id.to_s] }
        }
      )

      expect(response).not_to be_success
    end

    it "doesn't need the players in an array" do
      game = FactoryGirl.create(:elo_game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: player1.id.to_s },
          "1" => { players: player2.id.to_s }
        }
      )

      expect(response).to be_success
      result = response.result
      expect(result.winners).to eq([player1])
      expect(result.losers).to eq([player2])
      expect(result.game).to eq(game)
    end

    it "works with ties" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        teams: {
          "0" => { players: [player1.id.to_s], relation: "ties" },
          "1" => { players: [player2.id.to_s] },
        }
      )

      expect(response).to be_success
      result = response.result
      expect(result.winners).to eq([player1, player2])
    end

    context "ratings" do
      it "builds ratings for both players and increments the winner" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)

        ResultService.create(
          game,
          teams: {
            "0" => { players: [player1.id.to_s] },
            "1" => { players: [player2.id.to_s] }
          }
        )

        rating1 = player1.ratings.where(game_id: game.id).first
        rating2 = player2.ratings.where(game_id: game.id).first

        expect(rating1).not_to be_nil
        expect(rating1.value).to be > game.rater.default_attributes[:value]

        expect(rating2).not_to be_nil
        expect(rating2.value).to be < game.rater.default_attributes[:value]
      end

    end
  end

  describe "destroy" do
    it "returns a successful response if the result is destroyed" do
      game = FactoryGirl.create(:elo_game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      result = ResultService.create(
        game,
          teams: {
            "0" => { players: [player1.id.to_s] },
            "1" => { players: [player2.id.to_s] }
          }
      ).result

      response = ResultService.destroy(result)

      expect(response).to be_success
      expect(Result.find_by_id(result.id)).to be_nil
    end

    it "returns an unsuccessful response and does not destroy the result if it is not the most recent for both players" do
      game = FactoryGirl.create(:elo_game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)

      old_result = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player_1]), FactoryGirl.create(:team, rank: 2, players: [player_2])])
      FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player_1]), FactoryGirl.create(:team, rank: 2, players: [player_3])])

      response = ResultService.destroy(old_result)

      expect(response).not_to be_success
      expect(Result.find_by_id(old_result.id)).not_to be_nil
    end
  end
end
