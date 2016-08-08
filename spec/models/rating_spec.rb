require "spec_helper"

describe Rating do
  describe "active?" do
    it "is true if the player as played a game in the past 4 weeks" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, player: player, game: game)
      teams = [ FactoryGirl.create(:team, rank: 1, players: [player]),
                FactoryGirl.create(:team, rank: 2) ]
      result = FactoryGirl.create(:result, teams: teams, game: game, created_at: 5.weeks.ago)
      expect(rating.active?).to eq(false)
      teams = [ FactoryGirl.create(:team, rank: 1, players: [player]),
                FactoryGirl.create(:team, rank: 2) ]
      result = FactoryGirl.create(:result, teams: teams, game: game, created_at: 4.weeks.ago + 1.hour)
      expect(rating.active?).to eq(true)
    end
  end

  describe "as_json" do
    it "returns the json representation of the result" do
      player = FactoryGirl.build(:player, name: "John")
      rating = FactoryGirl.build(:rating, value: 1000, player: player)

      expect(rating.as_json).to eq({
        player: {
          name: player.name,
          email: player.email
        },
        value: 1000
      })
    end
  end

  describe "most_recent_result" do
    it "returns the most recent result for the game and player" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, player: player, game: game)
      result_5_weeks_ago = FactoryGirl.create(:result,
                                              teams: [ FactoryGirl.create(:team, rank: 1, players: [player]),
                                                          FactoryGirl.create(:team, rank: 2)],
                                              game: game,
                                              created_at: 5.weeks.ago)
      expect(rating.most_recent_result).to eq(result_5_weeks_ago)
      result_4_weeks_ago = FactoryGirl.create(:result,
                                              teams: [ FactoryGirl.create(:team, rank: 2, players: [player]),
                                                          FactoryGirl.create(:team, rank: 1)],
                                              game: game,
                                              created_at: 4.weeks.ago)
      expect(rating.most_recent_result).to eq(result_4_weeks_ago)
      result_6_weeks_ago = FactoryGirl.create(:result,
                                              teams: [ FactoryGirl.create(:team, rank: 1, players: [player]),
                                                          FactoryGirl.create(:team, rank: 2)],
                                              game: game,
                                              created_at: 6.weeks.ago)
      expect(rating.most_recent_result).to eq(result_4_weeks_ago)
    end
  end

  describe "destroy" do
    it "removes history events" do
      rating = FactoryGirl.create(:rating)
      history_event = FactoryGirl.create(:rating_history_event, rating: rating)

      rating.destroy

      expect(RatingHistoryEvent.find_by_id(history_event.id)).to be_nil
    end
  end

  describe "rewind!" do
    it "resets the rating to the previous rating" do
      rating = FactoryGirl.create(:rating, value: 1002, trueskill_mean: 52, trueskill_deviation: 22)
      FactoryGirl.create(:rating_history_event, rating: rating, value: 1001, trueskill_mean: 51, trueskill_deviation: 21)
      FactoryGirl.create(:rating_history_event, rating: rating, value: 1002, trueskill_mean: 52, trueskill_deviation: 22)

      rating.rewind!

      rating.reload

      expect(rating.value).to eq(1001)
      expect(rating.trueskill_mean).to eq(51)
      expect(rating.trueskill_deviation).to eq(21)
    end

    it "deletes the most recent history event" do
      rating = FactoryGirl.create(:rating, value: 1002)
      FactoryGirl.create(:rating_history_event, rating: rating, value: 1001)
      history_event = FactoryGirl.create(:rating_history_event, rating: rating, value: 1002)

      rating.rewind!

      expect(RatingHistoryEvent.find_by_id(history_event.id)).to be_nil
    end

    it "destroys the rating if there is only one history event" do
      rating = FactoryGirl.create(:rating, value: 1002)
      history_event = FactoryGirl.create(:rating_history_event, rating: rating, value: 1002)

      rating.rewind!

      expect(Rating.find_by_id(rating.id)).to be_nil
      expect(RatingHistoryEvent.find_by_id(history_event.id)).to be_nil
    end
  end
end
