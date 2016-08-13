require 'slack-notifier'

class ResultsController < ApplicationController
  before_action :set_game
  before_action :authenticate_user!


  def create
    multiplier = params[:multiplier] || 1
    opponent = params["result"]["teams"]["1"]["players"]
    render :new && return if opponent.nil?

    current_player = [@current_player.id.to_s]
    winner = params["relation"] == "defeated" ? current_player : opponent
    loser = params["relation"] == "defeated" ? opponent : current_player
    result = {
      teams: {
        "0" => { players: winner },
        "1" => { players: loser }
      }
    }

    winner_id = winner.kind_of?(Array) ? winner.first : winner
    loser_id = loser.kind_of?(Array) ? loser.first : loser

    slack_message = SlackMessage.new(winner_id, loser_id, @game, multiplier.to_i)

    response = nil
    1.upto(multiplier.to_i) do
      response = ResultService.create(@game, result)
    end

    slack_message.save_after_rating
    SlackService.notify(slack_message)

    update_streak_data(winner_id, loser_id)

    if response.success?
      redirect_to dashboard_path
    else
      @result = response.result
      render :new
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])
    response = ResultService.destroy(result)
    redirect_to :back
  end

  def new
    @result = Result.new
    (@game.max_number_of_teams || 20).times{|i| @result.teams.build rank: i}
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def update_streak_data(winner_id, loser_id)
    winner = Player.find_by_id(winner_id)
    winner.update_streak_data(@game, 10) if winner
    loser = Player.find_by_id(loser_id)
    loser.update_streak_data(@game, 10) if loser
  end
end
