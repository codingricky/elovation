class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :set_current_player

  def set_current_player
    @current_player = Player.find_by(email: current_user.email)
  end
end
