$:.unshift File.dirname(__FILE__)
require 'say'

Thread.abort_on_exception = true

if ENV['SLACK_API_TOKEN'] && !ENV['SLACK_API_TOKEN'].blank?
  Thread.new do
    SlackRubyBot::App.instance.run
  end
end
