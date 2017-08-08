class Api::LightsController < Api::ApiBaseController

  before_action :authenticate, only: [:index]

  def index
    last_result = Result.last
    winner = last_result.winner
    loser = last_result.loser
    no_color = 'black'
    winner_color = 'cyan'
    loser_color = 'red'
    all_ratings = Game.default.all_ratings_with_active_players.collect
    all_ratings.each do |rating|
      player = rating.player
      if player == winner
        color = winner_color
      elsif player == loser
        color = loser_color
      else
        color = no_color
      end
      player.color = color
    end
    render json: all_ratings
  end
end
