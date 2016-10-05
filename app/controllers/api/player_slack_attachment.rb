class Api::PlayerSlackAttachment
  def self.create_slack_attachment_from(player)
    attachment = {}
    attachment['color'] = 'green'
    attachment['title'] = player.name
    last_10_results = player.n_most_recent_results(10).collect{|r| "#{r.winner.name} defeated #{r.loser.name}"}.join("\n")

    attachment['fields'] = [create_field('wins', player.total_wins(Game.default), true),
                            create_field('losses', player.total_losses(Game.default), true),
                            create_field('winning %', ActionController::Base.helpers.number_to_percentage(player.win_loss_ratio(Game.default)), true),
                            create_field('winning % by day', winning_percentage_by_day(player), false),
                            create_field('last 10 results', last_10_results, false)]
    return attachment
  end

  def self.winning_percentage_by_day(player)
    days_of_the_week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
    days_of_the_week.collect do |day|
      "#{day} - #{ActionController::Base.helpers.number_to_percentage(player.winning_percentage_by_day(day))}"
    end.join("\n")
  end

  def self.create_field(title, value, short)
    {'title' => title, 'value' => value, 'short'=> short}
  end
end
