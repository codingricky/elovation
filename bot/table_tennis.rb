class TableTennis < SlackRubyBot::Commands::Base
  HELP = <<-FOO
               *show*                                         shows the leaderboard
          *if [winner] defeats [loser] n [times]*        hypothesise a result
          *[winner] defeats [loser] n [times]*           creates a result
          *[winner] h2h [loser]*                         shows the h2h record between two players
          *lookup [player]*                              looks up a player
          *help*                                         this message
  FOO

  match /help/ do |client, data, match|
    client.say(channel: data.channel, text: HELP)
  end

  match /show/ do |client, data, match|
    players = Game.default.all_ratings_with_active_players.collect{|r| r.player.as_string}.join("\n")
    client.say(channel: data.channel, text: players)
  end

   match /[a-zA-Z]+ (defeats|beats|kills|destroys|b) [a-zA-Z]+( [0-9] time(s)?)?/ do |client, data, match|
    message = create_result(match.to_s)
    client.say(channel: data.channel, text: message)
   end

  match /lookup [a-zA-Z]+/ do |client, data, match|
    text = match.to_s
    player = Player.with_name(text.sub("lookup ", ""))
    return "player not found" if player.nil?

    attachments = [Api::PlayerSlackAttachment.create_slack_attachment_from(player)]
    client.web_client.chat_postMessage(channel: data.channel, attachments: attachments)
  end

  match /[a-zA-Z]+ h2h [a-zA-Z]+/ do |client, data, match|
    split = match.to_s.split(" ")
    first_player_name = split.first
    second_player_name = split[2]

    first_player = Player.with_name(first_player_name)
    second_player = Player.with_name(second_player_name)

    wins = first_player.wins(Game.default, second_player)
    losses = first_player.losses(Game.default, second_player)
    ratio = ActionController::Base.helpers.number_to_percentage((wins.to_f/(wins + losses)) * 100, precision: 0)
    message = "*#{first_player.name}* H2H *#{second_player.name}* #{wins} wins #{losses} losses #{ratio}"
    client.say(channel: data.channel, text: message)
  end

  match /if [a-zA-Z]+ defeats [a-zA-Z]+( [0-9] time(s)?)?/ do |client, data, match|
    message = if_player_defeats_another_player(match.to_s)
    client.say(channel: data.channel, text: message)
  end

  def self.if_player_defeats_another_player(text)
    begin
      ActiveRecord::Base.transaction do
        @slack_message = create_result(text.sub("if ", ""))
        raise ActiveRecord::RecordNotFound
      end
    rescue
    end

    return ">>> *IF* #{@slack_message}"
  end

  def self.create_result(text)
    split_text = text.split
    winner = Player.with_name(split_text[0])
    return "winner can not be found" unless winner

    winner_id = winner.id

    loser = Player.with_name(split_text[2])
    return "loser can not be found" unless loser
    loser_id = loser.id

    times = split_text.count >= 3 ? split_text[3].to_i : 1
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    ResultService.create_times_without_slack(winner_id, loser_id, times).message
  end


  command 'lookup' do |client, data, match|
    user = client.lookup(data.user)
    client.say(channel: data.channel, text: user)
  end
end