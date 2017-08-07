class Api::PlayerController < Api::ApiBaseController


  before_action :authenticate, only: [:lookup]

  def lookup
    player = Player.with_name(params[:player])
    if player
      render json: {ranking: player.ranking, points: player.points, day: player.day_with_lowest_winning_percentage, color: player.color}
    else
      render json: {message: "#{params[:player]} not found"}, status: :not_found
    end
  end
end
