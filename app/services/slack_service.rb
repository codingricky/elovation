class SlackService

  def self.notify(slack_message, image_url=nil)
    if slack_web_url && !slack_web_url.blank?
      notifier = create_notifier

      if image_url
        notifier.ping slack_message.message, attachments: [{image_url:  image_url}]
      else
        notifier.ping slack_message.message
      end
    end
  end

  def self.show_leaderboard(image_url)
    if slack_web_url && !slack_web_url.blank?
      notifier = create_notifier
      notifier.ping "", attachments: [{image_url:  image_url}]
    end
  end

  def self.create_notifier
    Slack::Notifier.new slack_web_url, channel: Rails.configuration.slack_channel,
                        username: 'http://diustt.club'
  end

  def self.slack_web_url
    ENV["SLACK_WEB_URL"]
  end

 end