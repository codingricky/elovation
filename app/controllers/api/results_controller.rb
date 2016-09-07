class Api::ResultsController < ActionController::API

  def create
    winner_name = params[:winner]
    loser_name = params[:loser]

    winner = Player.with_name(winner_name)
    render json: {message: "winner can not be found"}, status: :bad_request unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    render json: {message: "loser can not be found"}, status: :bad_request unless loser; return if performed?
    loser_id = loser.id

    game = Game.first

    result = {
        teams: {
            "0" => { players: winner_id },
            "1" => { players: loser_id }
        }
    }

    times = params[:times].to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    1.upto(times) do
      ResultService.create(game, result)
    end
    render json: "created"
  end


  private

  def player_exists?(name)
    Player.find_by_name(name)
  end

end
