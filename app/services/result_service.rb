class ResultService

  def self.create_times_without_slack(winner_id, loser_id, times)
    create_times(winner_id, loser_id, times, false)
  end

  def self.create_times_with_slack(winner_id, loser_id, times)
    create_times(winner_id, loser_id, times, true)
  end

  def self.create_times(winner_id, loser_id, times, notify_slack)
    game = Game.first
    params = {
        teams: {
            "0" => { players: winner_id },
            "1" => { players: loser_id }
        }
    }

    slack_message = SlackMessage.new(winner_id, loser_id, game, times)
    result = nil
    1.upto(times) do
      result = ResultService.create(game, params)
    end
    slack_message.save_after_rating
    SlackService.notify(slack_message, nil) if notify_slack

    update_streak_data(winner_id, loser_id, game)
    result[:message] = slack_message.message
    return result
  end

  def self.update_streak_data(winner_id, loser_id, game)
    winner = Player.find_by_id(winner_id)
    winner.update_streak_data(game, 10) if winner
    loser = Player.find_by_id(loser_id)
    loser.update_streak_data(game, 10) if loser
  end

  def self.create(game, params)
    result = game.results.build

    next_rank = Team::FIRST_PLACE_RANK
    teams = (params[:teams] || {}).values.each.with_object([]) do |team, acc|
      players = Array.wrap(team[:players]).delete_if(&:blank?)
      acc << { rank: next_rank, players: players }

      next_rank = next_rank + 1 if team[:relation] != "ties"
    end

    teams = teams.reverse.drop_while{ |team| team[:players].empty? }.reverse

    teams.each do |team|
      result.teams.build rank: team[:rank], player_ids: team[:players]
    end

    if result.valid?
      Result.transaction do

        game.rater.update_ratings game, result.teams

        result.save!

        OpenStruct.new(
          success?: true,
          result: result
        )
      end
    else
      OpenStruct.new(
        success?: false,
        result: result
      )
    end
  end

  def self.destroy(result)
    return OpenStruct.new(success?: false) unless result.most_recent?

    Result.transaction do
      result.players.each do |player|
        player.rewind_rating!(result.game)
      end

      result.destroy

      OpenStruct.new(success?: true)
    end
  end
end
