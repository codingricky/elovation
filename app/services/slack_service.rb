class SlackService

  def self.notify(slack_message)
    if ENV["SLACK_WEB_URL"] && !ENV["SLACK_WEB_URL"].blank?
      notifier = Slack::Notifier.new ENV["SLACK_WEB_URL"], channel: Rails.configuration.slack_channel,
                                     username: 'http://diustt.club'

      notifier.ping slack_message.message
    end
  end
 end