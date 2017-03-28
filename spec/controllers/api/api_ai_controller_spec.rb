require 'spec_helper'

describe Api::ApiAiController do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:winner) { FactoryGirl.create(:player) }
  let!(:winner_rating) { FactoryGirl.create(:rating, player: winner, game: game) }
  let!(:loser) { FactoryGirl.create(:player) }
  let!(:loser_rating) { FactoryGirl.create(:rating, player: loser, game: game) }
  let(:valid_token) { ActionController::HttpAuthentication::Token.encode_credentials('valid_token') }

  before do
    request.env['HTTP_AUTHORIZATION'] = valid_token
    allow(User).to receive(:find_by).and_return(double("user"))
    allow(SlackService).to receive(:notify)
  end

  it 'should create a result' do
    post :create, params: {result: {parameters: {winner: winner.name, loser: loser.name}, metadata: {intentName: 'create.score'}}}

    expect(Result.all.count).to eql(1)
    result = Result.first
    expect(result.winners.first).to eql(winner)
    expect(result.losers.first).to eql(loser)
  end

end
