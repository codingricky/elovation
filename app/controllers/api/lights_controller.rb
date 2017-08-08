class Api::LightsController < Api::ApiBaseController

  before_action :authenticate, only: [:index]

  def index
    last_result = Result.last
    winner = last_result.winner
    loser = last_result.loser
    no_color = 'black'
    all_ratings = Game.default.all_ratings_with_active_players.collect
    all_ratings.each do |rating|
      rating.player.color = no_color unless [winner, loser].include?(rating.player)
    end
    render json: all_ratings
  end
end
