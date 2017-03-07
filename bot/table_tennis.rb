class TableTennis < SlackRubyBot::Commands::Base
  VICTORY_WORDS = %w(defeats beats kills destroys b defeated beat)


  HELP = <<-FOO
               *show*                                    shows the leaderboard
               *reverse show*                            shows the leaderboard in reverse
          *[winner] defeats [loser] n [times]*           creates a result
          *[winner] h2h [loser]*                         shows the h2h record between two players
          *lookup [player]*                              looks up a player
          *what's the best day to play [player]?*        tells you the best day to play a player to maximise your chances
          *help*                                         this message
  FOO

  match /^(?i)help/ do |client, data, match|
    logger.info 'matched help'
    client.say(channel: data.channel, text: HELP)
  end

  match /^(?i)show/ do |client, data, match|
    logger.info 'matched show'
    players = list_of_players.collect {|r, i| "#{i+1}. #{r.player.as_string}"}.join("\n")
    client.say(channel: data.channel, text: players)
  end


  match /^(?i)reverse show/ do |client, data, match|
    logger.info 'matched reverse show'
    players = list_of_players.reverse.collect {|r, i| "#{i+1}. #{r.player.as_string}"}.join("\n")
    client.say(channel: data.channel, text: players)
  end

  def list_of_players
    Game.default.all_ratings_with_active_players.enum_for(:each_with_index)
  end


  match /^(?i)what('s| is) the best day to play [a-zA-Z]+/ do |client, data, match|
    logger.info 'best day'
    player = Player.with_name(match.to_s.split(' ').last)
    if player.nil?
      client.say(channel: data.channel, text: "Player not found")
    else
      client.say(channel: data.channel, text: "The best day to play #{player.name} is #{player.day_with_lowest_winning_percentage}")
    end
  end


  match /^([a-zA-Z ]+) (defeats|beats|kills|destroys|b|defeated|beat) ([a-zA-Z ]+)([0-9] time(s)?)?/ do |client, data, match|
    logger.info "matched create a result #{match.to_s}"

    message = create_result(match)
    client.say(channel: data.channel, text: message)
  end

  match /^(?i)lookup [a-zA-Z]+/ do |client, data, match|
    text = match.to_s
    player = Player.with_name(text.sub("lookup ", ""))
    if player.nil?
      client.say(channel: data.channel, text: "Player not found")
    else
      attachments = [Api::PlayerSlackAttachment.create_slack_attachment_from(player)]
      client.web_client.chat_postMessage(channel: data.channel, attachments: attachments)
    end
  end

  match /^[a-zA-Z]+ (?i)h2h [a-zA-Z]+/ do |client, data, match|
    logger.info 'matched h2h'

    first_player_name = match[0]
    second_player_name = match[2]

    first_player = Player.with_name(first_player_name)
    second_player = Player.with_name(second_player_name)

    wins = first_player.wins(Game.default, second_player)
    losses = first_player.losses(Game.default, second_player)
    total = wins + losses
    ratio = ActionController::Base.helpers.number_to_percentage(wins.to_f/total * 100, precision: 0)
    message = "*#{first_player.name}* h2h *#{second_player.name}* #{wins} wins #{losses} losses #{ratio}"
    client.say(channel: data.channel, text: message)
  end

  def self.create_result(match)
    logger.info "creating result with #{match}"

    winner_name = match[1]
    loser_name = match[3]
    multiplier = match[4]

    winner = Player.with_name(winner_name.strip)
    return "winner can not be found" unless winner

    winner_id = winner.id
    loser = Player.with_name(loser_name.strip)
    return "loser can not be found" unless loser
    loser_id = loser.id

    times = multiplier.to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    ResultService.create_times_without_slack(winner_id, loser_id, times).message
  end


  def self.parse_times(text)
    matched_text = text.match(/[0-9]+ time/)
    return 1 unless matched_text

    times = matched_text.split(' ').to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times
    return times
  end


  command 'lookup' do |client, data, match|
    user = client.lookup(data.user)
    client.say(channel: data.channel, text: user)
  end
end