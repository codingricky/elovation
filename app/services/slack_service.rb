class SlackService

  def self.notify(slack_message, image_url)
    if ENV["SLACK_WEB_URL"] && !ENV["SLACK_WEB_URL"].blank?
      notifier = Slack::Notifier.new ENV["SLACK_WEB_URL"], channel: Rails.configuration.slack_channel,
                                     username: 'http://diustt.club'

      if image_url
        notifier.ping slack_message.message, attachments: [{image_url:  image_url}]
      else
        notifier.ping slack_message.message
      end
    end
  end
 end