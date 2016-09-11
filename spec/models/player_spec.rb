require "spec_helper"

describe Player do
  describe "as_json" do
    it "returns the json representation of the player" do
      FactoryGirl.create(:game)
      player = FactoryGirl.build(:player, name: "John Doe", email: "foo@example.com")

      expect(player.as_json).to eq({
        name: "John Doe",
        email: "foo@example.com",
        losses: 0,
        wins: 0,
        win_loss_ratio: 0,
        streak: 0
      })
    end
  end

  describe "validations" do
    context "name" do
      it "is required" do
        player = FactoryGirl.build(:player, name: nil)

        expect(player).not_to be_valid
        expect(player.errors[:name]).to eq(["can't be blank"])
      end

      it "must be unique" do
        FactoryGirl.create(:player, name: "Drew")
        player = FactoryGirl.build(:player, name: "Drew")

        expect(player).not_to be_valid
        expect(player.errors[:name]).to eq(["has already been taken"])
      end
    end

    context "email" do
      it "can be blank" do
        player = FactoryGirl.build(:player, email: "")
        expect(player).to be_valid
      end

      it "must be a valid email format" do
        player = Player.new
        player.email = "invalid-email-address"
        expect(player).not_to be_valid
        expect(player.errors[:email]).to eq(["is invalid"])
        player.email = "valid@example.com"
        player.valid?
        expect(player.errors[:email]).to eq([])
      end
    end
  end

  describe "name" do
    it "has a name" do
      player = FactoryGirl.create(:player, name: "Drew")

      expect(player.name).to eq("Drew")
    end
  end

  describe "recent_results" do
    it "returns 5 of the player's results" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      10.times { FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)]) }

      expect(player.recent_results.size).to eq(5)
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      Timecop.freeze(3.days.ago) do
        5.times { FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)]) }
      end

      Timecop.freeze(1.day.ago) do
        newer_results = 5.times.map { FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)]) }
      end

      expect(player.recent_results.sort).to eq(newer_results.sort)
    end

    it "orders results by created_at, descending" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])
      end

      Timecop.freeze(1.days.ago) do
        new = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])
      end

      expect(player.recent_results).to eq([new, old])
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      player = FactoryGirl.create(:player)
      rating = FactoryGirl.create(:rating, player: player)
      result = FactoryGirl.create(:result, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])

      player.destroy

      expect(Rating.find_by_id(rating.id)).to be_nil
      expect(Result.find_by_id(result.id)).to be_nil
    end
  end

  describe "ratings" do
    describe "find_or_create" do
      it "returns the rating if it exists" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)
        rating = FactoryGirl.create(:rating, game: game, player: player)

        expect do
          found_rating = player.ratings.find_or_create(game)
          expect(found_rating).to eq(rating)
        end.to_not change { player.ratings.count }
      end

      it "creates a rating and returns it if it doesn't exist" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)

        expect do
          expect(player.ratings.find_or_create(game)).not_to be_nil
        end.to change { player.ratings.count }.by(1)
      end
    end
  end

  describe "rewind_rating!" do
    it "resets the player's rating to the previous rating" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, game: game, player: player, value: 1002)
      FactoryGirl.create(:rating_history_event, rating: rating, value: 1001)
      FactoryGirl.create(:rating_history_event, rating: rating, value: 1002)

      player.rewind_rating!(game)

      expect(player.ratings.where(game_id: game.id).first.value).to eq(1001)
    end
  end

  describe "wins" do
    it "finds wins" do
      player1 = FactoryGirl.create(:player)
      player1WinTeam = FactoryGirl.create(:team, rank: 1, players: [player1])

      player2 = FactoryGirl.create(:player)
      player2WinTeam = FactoryGirl.create(:team, rank: 1, players: [player2])

      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, game: game, teams: [player1WinTeam, FactoryGirl.create(:team, players: [player2], rank: 2)])
      loss = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 2, players: [player1]), player2WinTeam])

      expect(player1.results.for_game(game).size).to eq(2)
      expect(player1.total_wins(game)).to eq(1)
      expect(player1.wins(game, player2)).to eq(1)
    end
  end

  describe 'win/loss' do
    it 'with a win and loss' do
      player1 = FactoryGirl.create(:player)
      player1WinTeam = FactoryGirl.create(:team, rank: 1, players: [player1])

      player2 = FactoryGirl.create(:player)
      player2WinTeam = FactoryGirl.create(:team, rank: 1, players: [player2])

      game = FactoryGirl.create(:game)
      win_for_player_1 = FactoryGirl.create(:result, game: game, teams: [player1WinTeam, FactoryGirl.create(:team, players: [player2], rank: 2)])
      loss_for_player_1 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 2, players: [player1]), player2WinTeam])

      expect(player1.win_loss_ratio(game)).to eq(50.0)
    end

    it 'defaults to zero' do
      player1 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      expect(player1.win_loss_ratio(game)).to eq(0)
    end
  end

  describe 'win/loss today' do
    it 'with a win and loss' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      create_result(game, player1, player2)
      create_result(game, player1, player2)
      create_result(game, player2, player1)
      create_result(game, player2, player1)

      Timecop.freeze(3.days.ago) do
        5.times { create_result(game, player1, player2) }
      end

      expect(player1.win_loss_ratio(game)).to be_within(77.77).of(0.01)
      expect(player1.win_loss_ratio_for_today(game)).to eq(50)
    end
  end

  describe 'streak' do
    it 'wins are counted' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      5.times { create_result(game, player1, player2) }

      player1.update_streak_data(game, 10)
      expect(player1.streak(game)).to eq(5)
    end

    it 'a loss breaks the streak' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)


      5.times { create_result(game, player1, player2) }
      create_result(game, player2, player1)

      player1.update_streak_data(game, 10)
      expect(player1.streak(game)).to eq(0)
    end
  end

  describe 'is active?' do
    it 'played a long time ago' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      Timecop.freeze(21.days.ago) do
        20.times { create_result(game, player1, player2) }
      end

      expect(player1.is_active?).to be_falsey
    end

    it 'played recently' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      Timecop.freeze(19.days.ago) do
        20.times { create_result(game, player1, player2) }
      end

      expect(player1.is_active?).to be_truthy
    end

    it 'played recently but not enough games' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      Timecop.freeze(15.days.ago) do
        5.times { create_result(game, player1, player2) }
      end

      Timecop.freeze(35.days.ago) do
        4.times { create_result(game, player1, player2) }
      end

      expect(player1.is_active?).to be_falsey
    end
  end

  describe 'last n' do
    it 'with a win and loss' do
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      # FactoryGirl.create(:result, game: game, teams: [player1WinTeam, FactoryGirl.create(:team, players: [player2], rank: 2)])
      create_result(game, player1, player2)
      create_result(game, player1, player2)
      create_result(game, player1, player2)
      create_result(game, player2, player1)
      create_result(game, player1, player2)

      expect(player1.last_n(game, 5)).to eq("WLWWW")
      expect(player2.last_n(game, 5)).to eq("LWLLL")
    end
  end

  def create_result(game, winner, loser)
    FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [winner]), FactoryGirl.create(:team, rank: 2, players: [loser])])
  end

  describe "ties" do
    it "finds ties" do
      player1 = FactoryGirl.create(:player)
      player1WinTeam = FactoryGirl.create(:team, rank: 1, players: [player1])

      player2 = FactoryGirl.create(:player)
      player2WinTeam = FactoryGirl.create(:team, rank: 1, players: [player2])

      game = FactoryGirl.create(:game)
      tie = FactoryGirl.create(:result, game: game, teams: [player1WinTeam, player2WinTeam])

      expect(player1.results.for_game(game).size).to eq(1)
      expect(player1.total_ties(game)).to eq(1)
      expect(player1.ties(game, player2)).to eq(1)
    end
  end

  describe "losses" do
    it "finds losses" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])
      loss = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 2, players: [player]), FactoryGirl.create(:team, rank: 1)])
      expect(player.results.for_game(game).size).to eq(2)
      expect(player.results.for_game(game).losses).to eq([loss])
    end
  end

  describe "against" do
    it "finds results against a specific opponent" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game, max_number_of_players_per_team: 2)
      opponent1 = FactoryGirl.create(:player)
      opponent2 = FactoryGirl.create(:player)
      win_against_opponent1 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2, players: [opponent1])])
      loss_against_opponent1 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 2, players: [player]), FactoryGirl.create(:team, rank: 1, players: [opponent1])])
      win_against_opponent2 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2, players: [opponent2])])
      opponent2_game_against_different_player = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1), FactoryGirl.create(:team, rank: 2, players: [opponent2])])
      win_with_opponent1 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player, opponent1]), FactoryGirl.create(:team, rank: 2)])

      expect(player.results.for_game(game).against(opponent1).sort_by(&:id)).to match_array [win_against_opponent1, loss_against_opponent1]
      expect(player.results.for_game(game).against(opponent2).sort_by(&:id)).to match_array [win_against_opponent2]
    end
  end

  describe 'with name' do
    it 'returns nil when no results' do
      expect(Player.with_name("Homer")).to eq(nil)
    end

    it 'returns player' do
      player = FactoryGirl.create(:player)
      expect(Player.with_name(player.name)).to eq(player)
    end

    it 'returns player based on first name' do
      player = FactoryGirl.create(:player, name: "John Smith")
      expect(Player.with_name("John")).to eq(player)
    end

    it 'returns player with case insensitivity' do
      player = FactoryGirl.create(:player, name: "John Smith")
      expect(Player.with_name("john")).to eq(player)
    end

    it 'returns the first active player when there are multiple players with the same name' do
      active_player = FactoryGirl.create(:player, name: "John Smith")
      loser = FactoryGirl.create(:player, name: "John Red")
      game = FactoryGirl.create(:game)
      20.times { create_result(game, active_player, loser) }

      expect(Player.with_name("john")).to eq(active_player)
    end
  end

  describe 'create default rating' do
    let!(:game) { FactoryGirl.create(:game) }
    let!(:player) { FactoryGirl.create(:player) }

    it 'should create a rating if not exists' do
      player.create_default_rating

      rating = Rating.find_by_player_id(player.id)
      expect(rating).to_not be_nil
      expect(rating.value).to eql(1000)
    end
  end
end
