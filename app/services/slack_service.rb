class SlackService

  def self.ping(winner, loser, multiplier)
    if ENV["SLACK_WEB_URL"]
      notifier = Slack::Notifier.new ENV["SLACK_WEB_URL"], channel: Rails.configuration.slack_channel,
                                     username: 'http://diustt.club'
      multiplier_message = multiplier.to_i > 1 ? "#{multiplier} times" : ""
      winner = winner.kind_of?(Array) ? winner.first : winner
      loser = loser.kind_of?(Array) ? loser.first : loser
      notifier.ping "#{Player.find(winner).name} defeated #{Player.find(loser).name} #{multiplier_message}"
    end
  end
 end