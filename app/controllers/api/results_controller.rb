class Api::ResultsController < ActionController::API

  def create
    winner_name = params[:winner]
    loser_name = params[:loser]

    winner_id = Player.find_by_name(winner_name).id
    loser_id = Player.find_by_name(loser_name).id

    game = Game.first

    result = {
        teams: {
            "0" => { players: winner_id },
            "1" => { players: loser_id }
        }
    }

    times = params[:times].to_i

    1.upto(times) do
      ResultService.create(game, result)
    end
    render json: "created"
  end

end
