class Api::SlackController < ActionController::API

  def slack
    if Rails.env != "development"
    render json: "invalid token", status: :unauthorized unless ENV["SLACK_TOKEN"] == params[:token]; return if performed?
    end

    text = params[:text]
    if text == "help"
      help
    elsif text == "show_leaderboard"
      show_leaderboard
    elsif text =="show"
      show
    elsif text.starts_with?("if ")
      # if_create_from_txt
    else
      create_from_txt
    end
  end

  def help
    help_text = <<-FOO
    usage: /tt [command]
          show                                      shows the leaderboard
          show_leaderboard                          shows the leaderboard image
          [winner] defeats [loser] n [times]        creates a result
          help                                      this message
    FOO

    render json: {text: help_text, response_type: "in_channel"}
  end

  def show
    players = Game.default.all_ratings_with_active_players.collect{|r| r.player.as_string}.join("\n")
    render json: {text: players, response_type: "in_channel"}
  end

  def create_from_txt
    message = create_result; return if performed?
    render json: {text: message, response_type: "in_channel"}
  end

  def create_result
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

    ResultService.create_times_with_slack(winner_id, loser_id, times).message
  end

  def if_create_from_txt
    begin
      ActiveRecord::Base.transaction do
        params[:text] = params[:text].sub("if ", "")
        @slack_message = create_result
        raise ActiveRecord::RecordNotFound
      end
    rescue
    end

    render json: {text: ">>> *IF* #{@slack_message}", response_type: "in_channel"}

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
