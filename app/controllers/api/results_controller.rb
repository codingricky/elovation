class Api::ResultsController < Api::ApiBaseController

  swagger_controller :api, "Results Controller"

  swagger_api :create do
    summary "Creates a result"
    param :header, 'Authorization', :string, :required, 'Authorization token in the form of "Token token=XXXX"'
    param :form, :winner, :string, :required, "winner of the match"
    param :form, :loser, :string, :required, "loser of the match"
    param :form, :times, :integer, :optional, "times the winner has won"
    response :success
    response :bad_request
  end

  swagger_api :active_players do
    summary "Gets active players"
    param :header, 'Authorization', :string, :required, 'Authorization token in the form of "Token token=XXXX"'
    response :success
  end

  before_action :authenticate, only: [:create, :active_players]


  include Swagger::Docs::ImpotentMethods

  swagger_controller :api_results, "Results Management"

  swagger_api :create do
    summary "Creates results"
    param :winner, :string, "Winner's name"
    param :loser, :string, "Loser's name"
    param :times, :int, :optional, "Times that someone has won"
    response :success
    response :bad_request
  end

  def create
    winner_name = params[:winner]
    winner_name ||= params[:parameters][:winner] if params[:parameters]
    loser_name = params[:loser]
    loser_name ||= params[:parameters][:loser] if params[:parameters]

    winner = Player.with_name(winner_name)
    render json: {message: "winner can not be found"}, status: :bad_request unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    render json: {message: "loser can not be found"}, status: :bad_request unless loser; return if performed?
    loser_id = loser.id

    times = params[:times].to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times
    slack_message = ResultService.create_times_with_slack(winner_id, loser_id, times).message
    render json: slack_message
  end

  def active_players
    game = Game.first
    render json: game.all_ratings_with_active_players.collect
  end

end
