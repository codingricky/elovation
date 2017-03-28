class Api::ApiAiController < Api::ApiBaseController
  def create
    parameters = params[:result][:parameters]
    winner_name = parameters[:winner]
    loser_name = parameters[:loser]

    winner = Player.with_name(winner_name)
    logger.info "winner=#{winner}"
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    logger.info "loser=#{loser}"
    loser_id = loser.id

    times = 1
    slack_message = ResultService.create_times_with_slack(winner_id, loser_id, times).message
    render json: slack_message
  end
end
