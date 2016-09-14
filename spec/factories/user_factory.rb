FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    api_key { ActionController::HttpAuthentication::Token.encode_credentials('valid_token') }
  end
end
