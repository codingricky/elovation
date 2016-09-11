class Api::ResultsController < Api::ApiBaseController

  swagger_controller :results, "Results Controller"

  swagger_api :create do
    summary "Creates a result"
    param :header, 'Authorization', :string, :required, 'Authorization token in the form of "Token token=XXXX"'
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

    times = params[:times].to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times
    slack_message = ResultService.create_times(winner_id, loser_id, times).message
    render json: slack_message
  end

  def leaderboard
    @players = Player.all.sort_by(&:name)
    @games = Game.all
  end

  def update_streak_data(winner_id, loser_id)
    winner = Player.find_by_id(winner_id)
    winner.update_streak_data(@game, 10) if winner
    loser = Player.find_by_id(loser_id)
    loser.update_streak_data(@game, 10) if loser
  end
end
