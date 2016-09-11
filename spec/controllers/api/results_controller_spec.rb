require "spec_helper"

describe Api::ResultsController do

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

  describe 'create' do
    context 'rejects invalid params' do
      it 'winner does not exist' do
        post :create, params: {winner: "no one"}, :authorization => 'string'

        expect(response).to have_http_status(:bad_request)
        expect_json(message: "winner can not be found")
        end

      it 'loser does not exist' do
        post :create, params: {winner: winner.name, loser: "loser"}

        expect(response).to have_http_status(:bad_request)
        expect_json(message: "loser can not be found")
      end

      it 'rejects invalid token' do
        allow(User).to receive(:find_by).and_return(nil)

        post :create

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'creating results' do

      it 'should be a success' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 1}

        expect(response).to have_http_status(:success)
      end


      it 'should create a result' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 1}


        expect(Result.all.count).to eql(1)
      end

      it 'should create a result with the correct game' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 1}

        result = Result.first
        expect(result.game).to eql(game)
      end

      it 'should create a result with the correct winner and loser' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 1}

        result = Result.first
        expect(result.winners.first).to eql(winner)
        expect(result.losers.first).to eql(loser)
      end

      it 'should use the multiplier' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 3}

        expect(Result.all.count).to eql(3)
      end

      it 'defaults to zero if there is no times params' do
        post :create, params: {winner: winner.name, loser: loser.name}

        expect(Result.all.count).to eql(1)
      end

      it 'defaults to five if there is the times param is larger than five' do
        post :create, params: {winner: winner.name, loser: loser.name, times: 6}

        expect(Result.all.count).to eql(5)
      end

      it 'can find winner by first name' do
        winner = FactoryGirl.create(:player, name: "Elliott Murray")
        FactoryGirl.create(:rating, player: winner, game: game)

        post :create, params: {winner: "Elliott", loser: loser.name, times: 1}
        expect(Result.all.count).to eql(1)
      end

      it 'can find loser by first name' do
        loser = FactoryGirl.create(:player, name: "Elliott Murray")
        FactoryGirl.create(:rating, player: loser, game: game)

        post :create, params: {winner: winner.name, loser: "Elliott", times: 1}
        expect(Result.all.count).to eql(1)
      end
    end

  end
end