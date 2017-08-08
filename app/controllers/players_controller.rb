class PlayersController < ApplicationController
  before_action :set_player, only: [:edit, :destroy, :show, :update]
  before_action :authenticate_user!

  def create
    @player = Player.new(player_params)
    if @player.save
      @player.create_default_rating
      User.find_or_create_by(email: @player.email) do |user|
        user.password = Devise.friendly_token[0,20]
      end
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    @player.destroy if @player.results.empty?
    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @player = Player.new
  end

  def show
  end

  def update
    if @player.update_attributes(player_params)
      redirect_to player_path(@player)
    else
      render :edit
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :email, :avatar, :color)
  end
end
