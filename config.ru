# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../bot/table_tennis', __FILE__)

Thread.abort_on_exception = true

if ENV['SLACK_API_TOKEN'] && !ENV['SLACK_API_TOKEN'].blank?
  Thread.new do
    SlackRubyBot::App.instance.run
  end
end


run Elovation::Application
