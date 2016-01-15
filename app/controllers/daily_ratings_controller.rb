class DailyRatingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @game = Game.find(params[:id])
  end
end
