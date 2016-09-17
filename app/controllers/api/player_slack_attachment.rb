class Api::PlayerSlackAttachment
  def self.create_slack_attachment_from(player)
    attachment = {}
    attachment['color'] = 'green'
    attachment['title'] = player.name
    attachment['fields'] = [create_field('wins', player.total_wins(Game.default), true),
                            create_field('losses', player.total_losses(Game.default), true),
                            create_field('ratio', ActionController::Base.helpers.number_to_percentage(player.win_loss_ratio(Game.default)), true)]

    results = player.n_most_recent_results(10).collect{|r| "*#{r.winner.name}* defeated *#{r.loser.name}*"}.join("\n")
    attachment['text'] = "*Last 10 results*\n#{results}"
    return attachment
  end

  def self.create_field(title, value, short)
    {'title' => title, 'value' => value, 'short'=> short}
  end
end
