class Api::LightsController < Api::ApiBaseController

  before_action :authenticate, only: [:index]

  def index
    all_ratings = Game.default.all_ratings_with_active_players.collect
    render json: all_ratings
  end
end
