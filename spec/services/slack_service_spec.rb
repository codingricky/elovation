require "spec_helper"

describe SlackService do
  let!(:actual_message) {double("hello")}
  let!(:message) {double("message")}
  let!(:slack_notifier) {double("slack notifier")}
  let!(:image_url) {"http://image.com"}
  let!(:slack_web_url) {ENV["SLACK_WEB_URL"] = "SLACK WEB URL"}

  context 'notify' do
    it 'should not notify anyone if environment variable not set' do
      ENV["SLACK_WEB_URL"] = ""
      expect(Slack::Notifier).not_to receive(:new)
      SlackService.notify(nil, nil)
    end

    it 'notify' do
      allow(message).to receive(:message).and_return(actual_message)
      allow(Slack::Notifier).to receive(:new).with(any_args).and_return(slack_notifier)
      expect(slack_notifier).to receive(:ping).with(actual_message, attachments: [{image_url: image_url}])

      SlackService.notify(message, image_url)
    end

    it 'notify without image_url' do
      allow(message).to receive(:message).and_return(actual_message)

      allow(Slack::Notifier).to receive(:new).with(any_args).and_return(slack_notifier)
      expect(slack_notifier).to receive(:ping).with(actual_message)

      SlackService.notify(message, nil)

    end

  end
end
