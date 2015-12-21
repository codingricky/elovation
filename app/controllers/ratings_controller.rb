class RatingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @game = Game.find(params[:game_id])
  end
end
