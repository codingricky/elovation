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
      if_create_from_txt
    elsif text.starts_with?("lookup ")
      lookup text
    else
      split = text.split(' ')
      first_token = split.first
      if (is_player?(first_token))
        handle_player_commands(split)
      else
        render json: {text: "command not recognised"}
      end
    end
  end

  def handle_player_commands(split)
    second_token = split.second
    if (second_token == "h2h")
      show_head_to_head(split)
    else
      create_result_from_txt
    end
  end

  def help
    help_text = <<-FOO
    usage: /tt [command]
          *show*                                         shows the leaderboard
          *show_leaderboard*                             shows the leaderboard image
          *if [winner] defeats [loser] n [times]*        hypothesise a result
          *[winner] defeats [loser] n [times]*           creates a result
          *[winner] h2h [loser]*                         shows the h2h record between two players
          *lookup [player]*                              looks up a player
          *help*                                         this message
    FOO

    render json: {text: help_text, response_type: "in_channel"}
  end

  def lookup(text)
    player = Player.with_name(text.sub("lookup ", ""))
    render json: {text: "player not found", response_type: "in_channel"} if player.nil?; return if performed?

    player_string = player.as_string
    results = player.n_most_recent_results(10).collect{|r| "*#{r.winner.name}* defeated *#{r.loser.name}*"}.join("\n")
    render json: {text: "#{player_string}\n*Last 10 results*\n#{results}", response_type: "in_channel"}
  end

  def show
    players = Game.default.all_ratings_with_active_players.collect{|r| r.player.as_string}.join("\n")
    render json: {text: players, response_type: "in_channel"}
  end

  def create_result_from_txt
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

    ResultService.create_times_without_slack(winner_id, loser_id, times).message
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

  private

  def is_player?(name)
    Player.with_name(name)
  end

  def show_head_to_head(split)
    first_player_name = split.first
    second_player_name = split[2]

    first_player = Player.with_name(first_player_name)
    second_player = Player.with_name(second_player_name)

    wins = first_player.wins(Game.default, second_player)
    losses = first_player.losses(Game.default, second_player)
    ratio = ActionController::Base.helpers.number_to_percentage((wins.to_f/(wins + losses)) * 100, precision: 0)
    render json: {text: "*#{first_player.name}* H2H *#{second_player.name}* #{wins} wins #{losses} losses #{ratio}", response_type: "in_channel"}
  end
end
