require 'spec_helper'

RSpec.describe "API results", :type => :request do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:user) {FactoryGirl.create(:user)}
  let!(:winner) { FactoryGirl.create(:player) }
  let!(:winner_rating) { FactoryGirl.create(:rating, player: winner, game: game) }
  let!(:loser) { FactoryGirl.create(:player) }
  let!(:loser_rating) { FactoryGirl.create(:rating, player: loser, game: game) }

  it "creates a result" do
    ENV["SLACK_WEB_URL"] = "some callback url"
    notifier = double('notifier')
    allow(Slack::Notifier).to receive(:new).and_return(notifier)
    expect(notifier).to receive(:ping)

    post '/api/results', params: {winner: winner.name, loser: loser.name, times: 3}, headers: {'Authorization' => "Token #{user.api_key}"}

    expect(response).to have_http_status(:success)

    expect(winner.total_wins(game)).to be(3)
    expect(winner.total_losses(game)).to be(0)
    expect(loser.total_wins(game)).to be(0)
    expect(loser.total_losses(game)).to be(3)
  end

end