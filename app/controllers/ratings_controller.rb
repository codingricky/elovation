class RatingsController < ApplicationController
  def index
    Rails.cache.fetch("game", expires_in: 1.hour) do
      @game = Game.find(params[:game_id])
    end
  end
end
