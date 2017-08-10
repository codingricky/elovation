class TableTennis < SlackRubyBot::Commands::Base
  # TONY_USER_ID = 'U1ULH4DQS'
  TONY_USER_ID = 'U0SF510BZ'
  VICTORY_WORDS = %w(defeats beats kills destroys b defeated beat)
  SUPPORTED_COLOURS = %w(green purple red yellow black pink white cyan blue)

  HELP = <<-FOO
               *show*                                    shows the leaderboard
               *show colours*                            shows the the colours
               *show full*                                    shows the full leaderboard
               *reverse show*                            shows the leaderboard in reverse
          *[winner] defeats [loser] n [times]*           creates a result
          *[winner] h2h [loser]*                         shows the h2h record between two players
          *lookup [player]*                              looks up a player
          *who does [player] mine?*                      see which player does this player mine the most
          *what's the best day to play [player]?*        tells you the best day to play a player to maximise your chances
          *change [player]'s colour to [new colour]*     change a player's colour
          *help*                                         this message
  FOO

  match /^(?i)help/ do |client, data, match|
    logger.info 'matched help'
    client.say(channel: data.channel, text: HELP)
  end

  match /^(?i)show colours/ do |client, data, match|
    logger.info 'matched show colours'
    leaderboard = Game.leaderboard_as_slack_attachments
    SlackService.create_notifier.ping('', attachments: leaderboard)
  end

  match /^(?i)who does ([a-zA-Z ]+) mine?/ do |client, data, match|
    logger.info 'mine'
    player_name = match[1]
    player = Player.with_name(player_name)
    points_table = player.points_table
    points_table = points_table.sort_by {|k,v| v}.reverse
    message = points_table.select{|name, points| points != 0}.collect {|name, points| "#{name} *#{points}* points"}.join("\n")
    client.say(channel: data.channel, text: message)
  end

  match /^(?i)(change|update) ([a-zA-Z ]+)'s (colour|color) to ([a-zA-Z ]+)/ do |client, data, match|
    logger.info 'matched show colours'
    player_name = match[2]
    colour = match[4]
    player = Player.with_name(player_name)
    if !player
      client.say(channel: data.channel, text: "#{player_name} could not be found")
    elsif !SUPPORTED_COLOURS.include?(colour)
      client.say(channel: data.channel, text: "Colour must be one of #{SUPPORTED_COLOURS.join(', ')}")
    else
      player.update_attribute(:color, colour)
      client.say(channel: data.channel, text: "updated #{player_name}'s colour to #{colour}")
    end
  end


  match /^(?i)show full/ do |client, data, match|
    logger.info 'matched show full'
    players = Game.full_leaderboard_as_string
    client.say(channel: data.channel, text: players)
  end

  match /^(?i)show/ do |client, data, match|
    logger.info 'matched show'
    players = Game.leaderboard_as_string
    client.say(channel: data.channel, text: players)
  end

  match /^(?i)reverse show/ do |client, data, match|
    logger.info 'matched reverse show'
    reverse_show(client, data)
  end

  match /^(?i)woes/ do |client, data, match|
    logger.info 'matched woes'
    reverse_show(client, data)
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

  match /^([a-zA-Z ]+) (h2h|H2H) ([a-zA-Z ]+)/ do |client, data, match|
    logger.info 'matched h2h'
    first_player_name = match[1]
    second_player_name = match[3]

    first_player = Player.with_name(first_player_name)
    if first_player.nil?
      client.say(channel: data.channel, text: "#{first_player_name} not found")
    end

    second_player = Player.with_name(second_player_name)
    if second_player.nil?
      client.say(channel: data.channel, text: "#{second_player_name} not found")
    end

    if first_player && second_player
      results = first_player.head_to_head(second_player)
      message = "*#{first_player.name}* h2h *#{second_player.name}* #{results[:wins]} wins #{results[:losses]} losses #{results[:ratio]}"
      client.say(channel: data.channel, text: message)
    end
  end

  match /.*/ do |client, data, match|
    puts data.user
    Quote.create(quote: data.text) if (data.user == TONY_USER_ID)
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

  def self.reverse_show(client, data)
    players = Game.leaderboard.reverse.enum_for(:each_with_index).collect {|r, i| "#{i+1}. #{r.player.as_string}"}.join("\n")
    client.say(channel: data.channel, text: players)
  end

end
