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

  context 'create a result' do
    it 'happy case' do
      post :create, params: create_result_params(winner.name, loser.name)

      expect(Result.all.count).to eql(1)
      result = Result.first
      expect(result.winners.first).to eql(winner)
      expect(result.losers.first).to eql(loser)
    end

    it 'should not create anything if winner/loser are the same' do
      post :create, params: create_result_params(winner.name, winner.name)

      expect(Result.all).to be_empty
    end

    it 'with times' do
      post :create, params: create_result_params_with_times(winner.name, loser.name, 5)
      expect(Result.all.count).to eql(5)
    end

    it 'only create a max of 5 results' do
      post :create, params: create_result_params_with_times(winner.name, loser.name, 15)
      expect(Result.all.count).to eql(5)
    end
  end

  def create_result_params(winner, loser)
    {result: {parameters: {winner: winner, loser: loser}, metadata: {intentName: 'create.score'}}}
  end

  def create_result_params_with_times(winner, loser, times)
    {result: {parameters: {winner: winner, loser: loser, times: times}, metadata: {intentName: 'create.score'}}}
  end


end
