require 'spec_helper'

RSpec.describe "Slack", :type => :request do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:user) {FactoryGirl.create(:user)}
  let!(:winner) { FactoryGirl.create(:player, name: "Roger") }
  let!(:winner_rating) { FactoryGirl.create(:rating, player: winner, game: game) }
  let!(:loser) { FactoryGirl.create(:player, name: "Rafa") }
  let!(:loser_rating) { FactoryGirl.create(:rating, player: loser, game: game) }
  let!(:token) { "ABC" }

  it "creates a result" do
    ENV["SLACK_TOKEN"] = token
    ENV["SLACK_WEB_URL"] = "some callback url"
    notifier = double('notifier')
    allow(Slack::Notifier).to receive(:new).and_return(notifier)
    expect(notifier).to receive(:ping)

    post '/api/slack', params: {text: "#{winner.name} defeats #{loser.name} 3 times", token: token}

    expect(response).to have_http_status(:success)

    expect(winner.total_wins(game)).to be(3)
    expect(winner.total_losses(game)).to be(0)
    expect(loser.total_wins(game)).to be(0)
    expect(loser.total_losses(game)).to be(3)
  end

end