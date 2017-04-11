class Api::ApiAiController < Api::ApiBaseController
  def create
    parameters = params[:result][:parameters]
    winner_name = parameters[:winner]
    loser_name = parameters[:loser]
    times = parameters[:times].to_i if parameters[:times]
    times ||= 1

    winner = Player.with_name(winner_name)
    unless winner
      message = "#{winner_name} not found. Who won the match?"
      json_result = {speech: message, displayText: message, data: {google: {expect_user_response: true}}}
      render json: json_result
      return
    end

    logger.info "winner=#{winner}"
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    unless loser
      message = "#{loser_name} not found. Who lost the match?"
      json_result = {speech: message, displayText: message, data: {google: {expect_user_response: true}}}
      render json: json_result
      return
    end

    logger.info "loser=#{loser}"
    loser_id = loser.id

    if winner_id == loser_id
      slack_message = 'Winner and loser can not be the same'
      ResultService.notify(slack_message)
      render json: slack_message
    else
      result = ResultService.create_times_with_slack(winner_id, loser_id, times)
      message = "#{winner_name} has #{result.winner_rating_after} points now. #{loser_name} has #{result.loser_rating_after} points now."
      json_result = {speech: message, displayText: message}
      render json: json_result
    end
  end
end
