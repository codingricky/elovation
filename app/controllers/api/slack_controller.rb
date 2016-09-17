class Api::SlackController < ActionController::API

  COMMANDS = {/[hH]elp/ => :help,
             /show leaderboard/ => :show_leaderboard,
             /show/ => :show,
             /if [a-zA-Z]+ [a-zA-Z]+ [a-zA-Z]+( [0-9] time(s)?)?/ => :if_player_defeats_another_player,
             /[a-zA-Z]+ [a-zA-Z]+ [a-zA-Z]+( [0-9] time(s)?)?/ => :player_defeats_another_player,
             /[a-zA-Z]+ h2h [a-zA-Z]+/ => :player_h2h_another_player,
             /lookup [a-zA-Z]+/ => :lookup_player}

  def slack
    if Rails.env != "development"
    render json: "invalid token", status: :unauthorized unless ENV["SLACK_TOKEN"] == params[:token]; return if performed?
    end

    command = COMMANDS.keys.find{|c| c =~ params[:text]}
    render json: {text: "`#{command}` not recognised"} unless command; return if performed?

    self.send(COMMANDS[command], params[:text])
  end

  def help(text)
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

  def show(text)
    players = Game.default.all_ratings_with_active_players.collect{|r| r.player.as_string}.join("\n")
    render json: {text: players, response_type: "in_channel"}
  end

  def show_leaderboard(text)
    SlackService.show_leaderboard(url_for(controller: '/leaderboard', action: 'show_image'))
    render json: {text: ""}
  end

  def player_defeats_another_player(text)
    message = create_result(text); return if performed?
    render json: {text: message, response_type: "in_channel"}
  end

  def create_result(text)
    split_text = text.split
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

  def if_player_defeats_another_player(text)
    begin
      ActiveRecord::Base.transaction do
        @slack_message = create_result(text.sub("if ", ""))
        raise ActiveRecord::RecordNotFound
      end
    rescue
    end

    render json: {text: ">>> *IF* #{@slack_message}", response_type: "in_channel"}
  end

  def player_h2h_another_player(text)
    split = text.split(" ")
    first_player_name = split.first
    second_player_name = split[2]

    first_player = Player.with_name(first_player_name)
    second_player = Player.with_name(second_player_name)

    wins = first_player.wins(Game.default, second_player)
    losses = first_player.losses(Game.default, second_player)
    ratio = ActionController::Base.helpers.number_to_percentage((wins.to_f/(wins + losses)) * 100, precision: 0)
    render json: {text: "*#{first_player.name}* H2H *#{second_player.name}* #{wins} wins #{losses} losses #{ratio}", response_type: "in_channel"}
  end

  def lookup_player(text)
    player = Player.with_name(text.sub("lookup ", ""))
    render json: {text: "player not found", response_type: "in_channel"} if player.nil?; return if performed?

    attachments = [Api::PlayerSlackAttachment.create_slack_attachment_from(player)]
    render json: {response_type: "in_channel", attachments: attachments}
  end
end
