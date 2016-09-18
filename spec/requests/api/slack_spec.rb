require 'spec_helper'

def winner_defeats_loser_3_times
end

RSpec.describe "Slack", :type => :request do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:user) {FactoryGirl.create(:user)}
  let!(:winner) { FactoryGirl.create(:player, name: "Roger") }
  let!(:winner_rating) { FactoryGirl.create(:rating, player: winner, game: game) }
  let!(:loser) { FactoryGirl.create(:player, name: "Rafa") }
  let!(:loser_rating) { FactoryGirl.create(:rating, player: loser, game: game) }
  let!(:token) { "ABC" }
  let!(:winner_defeats_loser_3_times) {"#{winner.name} defeats #{loser.name} 3 times" }

  before do
    ENV["SLACK_TOKEN"] = token
    allow(SlackService).to receive(:notify)
  end

  it "looks up a player" do
    post '/api/slack', params: {text: winner_defeats_loser_3_times, token: token}

    post '/api/slack', params: {text: "lookup #{winner.name}", token: token}
    expect(response).to have_http_status(:success)
    attachment = JSON.parse(response.body)["attachments"].first
    last_10_results = attachment["fields"].last
    expect(last_10_results['value']).to include("Roger defeated Rafa
Roger defeated Rafa
Roger defeated Rafa")
  end

  it "creates a result" do
    post '/api/slack', params: {text: winner_defeats_loser_3_times, token: token}

    expect(response).to have_http_status(:success)

    expect(winner.total_wins(game)).to be(3)
    expect(winner.total_losses(game)).to be(0)
    expect(loser.total_wins(game)).to be(0)
    expect(loser.total_losses(game)).to be(3)

    expect(JSON.parse(response.body)["text"]).to include("*Roger* (~0~ - 1393) defeated *Rafa* (~0~ - -56) 3 times")
  end

  it "shows the h2h" do
    post '/api/slack', params: {text: winner_defeats_loser_3_times, token: token}

    post '/api/slack', params: {text: "#{winner.name} h2h #{loser.name}", token: token}
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["text"]).to include("*Roger* H2H *Rafa* 3 wins 0 losses 100%")
  end

  it "shows help" do
    post '/api/slack', params: {text: "help", token: token}

    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["text"]).not_to be_nil
  end

  it "if shows the hypothetical matchup" do
    post '/api/slack', params: {text: "if #{winner.name} beats #{loser.name}", token: token}

    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["text"]).to include(">>> *IF* :table_tennis_paddle_and_ball: *Roger* (~0~ - 788) defeated *Rafa* (~0~ - -91)")
  end

end
