class Api::ResultsController < Api::ApiBaseController


  before_action :authenticate, only: [:create, :active_players]

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
