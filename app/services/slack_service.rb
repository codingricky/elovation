class SlackService

  def self.notify(message)
    if ENV["SLACK_WEB_URL"]
      notifier = Slack::Notifier.new ENV["SLACK_WEB_URL"], channel: Rails.configuration.slack_channel,
                                     username: 'http://diustt.club'

      multiplier_message = message[:multiplier] > 1 ? "#{message[:multiplier]} times" : ""
      winner_name = Player.find(message[:winner_id]).name
      winner_rating_before = message[:winner_rating_before]
      winner_rating_after = message[:winner_rating_after]

      loser_name = Player.find(message[:loser_id]).name
      loser_rating_before = message[:loser_rating_before]
      loser_rating_after = message[:loser_rating_after]

      notifier.ping "*#{winner_name}* (~#{winner_rating_before}~ - #{winner_rating_after}) defeated *#{loser_name}* (~#{loser_rating_before}~ - #{loser_rating_after}) #{multiplier_message}"
    end
  end
 end