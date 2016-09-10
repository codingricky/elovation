class Api::ResultsController < Api::ApiBaseController

  swagger_controller :results, "Results Controller"

  swagger_api :create do
    summary "Creates a result"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, :winner, :string, :required, "winner of the match"
    param :form, :loser, :string, :required, "loser of the match"
    param :form, :times, :integer, :optional, "times the winner has won"
    response :success
    response :bad_request
  end

  before_action :authenticate, only: [:create]


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

end
