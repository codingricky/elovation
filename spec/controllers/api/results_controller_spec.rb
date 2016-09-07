require "spec_helper"

describe Api::ResultsController do
  describe 'create' do
    let!(:game) { FactoryGirl.create(:game) }
    let!(:winner) { FactoryGirl.create(:player) }
    let!(:loser) { FactoryGirl.create(:player) }

    context 'rejects invalid params' do
      it 'winner does not exist' do
        post :create, params: {winner: "no one"}

        expect(response).to have_http_status(:bad_request)
        expect_json(message: "winner can not be found")
        end

      it 'loser does not exist' do
        post :create, params: {winner: winner.name, loser: "loser"}

        expect(response).to have_http_status(:bad_request)
        expect_json(message: "loser can not be found")
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
    end

  end

end