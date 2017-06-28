require 'csv'

class Api::ResultsController < Api::ApiBaseController

  before_action :authenticate, only: [:create, :active_players]

  def create
    winner_name = params[:winner]
    winner_name ||= result_params[:winner] if result_params
    loser_name = params[:loser]
    loser_name ||= result_params[:loser] if result_params

    winner = Player.with_name(winner_name)
    logger.info "winner=#{winner}"
    render json: {message: "winner can not be found"}, status: :bad_request unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    logger.info "loser=#{loser}"
    render json: {message: "loser can not be found"}, status: :bad_request unless loser; return if performed?
    loser_id = loser.id

    times = params[:times].to_i
    times = result_params[:times].to_i if result_params

    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times
    result = ResultService.create_times_with_slack(winner_id, loser_id, times)
    message = "#{winner_name} has #{result.winner_rating_after} points now. #{loser_name} has #{result.loser_rating_after} points now."
    render json: {message: message}
  end

  def active_players
    game = Game.first
    render json: game.all_ratings_with_active_players.collect
  end

  private

  def result_params
    params[:result][:parameters] if params[:result] && params[:result][:parameters]
  end

end
