class Api::SlackController < ActionController::API

  def create_from_txt
    render json: "invalid token", status: :unauthorized unless ENV["SLACK_TOKEN"] == params[:token]; return if performed?

    split_text = params[:text].split
    winner = Player.with_name(split_text[0])
    render json: {text: "winner can not be found"} unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(split_text[2])
    render json: {text: "loser can not be found"} unless loser; return if performed?
    loser_id = loser.id

    times = split_text.count >= 3 ? split_text[3].to_i : 1
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    slack_message = ResultService.create_times_without_slack(winner_id, loser_id, times).message
    render json: {text: slack_message, response_type: "in_channel"}
  end


  def show_leaderboard
    SlackService.show_leaderboard(url_for(controller: '/leaderboard', action: 'show_image'))
    render json: {text: ""}
  end

  def update_streak_data(winner_id, loser_id)
    winner = Player.find_by_id(winner_id)
    winner.update_streak_data(@game, 10) if winner
    loser = Player.find_by_id(loser_id)
    loser.update_streak_data(@game, 10) if loser
  end

end
