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

    if ENV["SLACK_WEB_URL"]
      notifier = Slack::Notifier.new ENV["SLACK_WEB_URL"], channel: '#tabletennis',
                                                           username: 'http://diustt.club'
      multiplier_message = multiplier.to_i > 2 ? "#{multiplier} times" : ""
      winner = winner.kind_of?(Array) ? winner.first : winner
      loser = loser.kind_of?(Array) ? loser.first : loser
      notifier.ping "#{Player.find(winner).name} defeated #{Player.find(loser).name} #{multiplier_message}"
    end

    response = nil
    1.upto(multiplier.to_i) do
      response = ResultService.create(@game, result)
    end

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
end
