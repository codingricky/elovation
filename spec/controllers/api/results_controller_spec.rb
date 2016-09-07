require "spec_helper"

describe Api::ResultsController do
  describe 'create' do

    context 'creating results' do

      let!(:game) { FactoryGirl.create(:game) }
      let!(:winner) { FactoryGirl.create(:player) }
      let!(:loser) { FactoryGirl.create(:player) }

      it 'should be a success' do
        post :create, {winner: winner.name, loser: loser.name, times: 1}

        expect(response).to have_http_status(:success)
      end


      it 'should create a result' do
        post :create, {winner: winner.name, loser: loser.name, times: 1}


        expect(Result.all.count).to eql(1)
      end

      it 'should create a result with the correct game' do
        post :create, {winner: winner.name, loser: loser.name, times: 1}

        result = Result.first
        expect(result.game).to eql(game)
      end

      it 'should create a result with the correct winner and loser' do
        post :create, {winner: winner.name, loser: loser.name, times: 1}

        result = Result.first
        expect(result.winners.first).to eql(winner)
        expect(result.losers.first).to eql(loser)
      end

      it 'should use the multiplier' do
        post :create, {winner: winner.name, loser: loser.name, times: 3}

        expect(Result.all.count).to eql(3)
      end
    end

  end

end