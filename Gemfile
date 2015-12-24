source 'https://rubygems.org'

ruby '2.2.3'


gem 'omniauth-google-oauth2'
gem 'devise'
gem 'puma'


gem 'paperclip'
gem 'aws-sdk', '< 2.0'

gem 'rails', '~> 4.2.5'
gem 'pg'

gem 'sass-rails', '~> 4.0.3'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'chartkick'

gem 'dynamic_form'
gem 'elo'
gem 'trueskill', github: 'saulabs/trueskill', require: 'saulabs/trueskill'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'mocha'
  gem 'rspec-rails', '~> 2.14.2'
  gem 'timecop'
end
