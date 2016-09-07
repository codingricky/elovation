require "spec_helper"

describe Api::ResultsController do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:winner) { FactoryGirl.create(:player) }
  let!(:loser) { FactoryGirl.create(:player) }

  describe 'create' do

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

      it 'can find winner by first name' do
        winner = FactoryGirl.create(:player, name: "Elliott Murray")
        post :create, params: {winner: "Elliott", loser: loser.name, times: 1}
        expect(Result.all.count).to eql(1)
      end

      it 'can find loser by first name' do
        loser = FactoryGirl.create(:player, name: "Elliott Murray")
        post :create, params: {winner: winner.name, loser: "Elliott", times: 1}
        expect(Result.all.count).to eql(1)
      end
    end

  end


  describe 'create via txt' do
    let!(:game) { FactoryGirl.create(:game) }
    let!(:winner) { FactoryGirl.create(:player) }
    let!(:winner_name) { winner.name.split[0] }
    let!(:loser) { FactoryGirl.create(:player) }
    let!(:loser_name) { loser.name.split[0] }
    let!(:token) { ENV["SLACK_TOKEN"] = "ABC"}
    let!(:defeats_txt) {"#{winner_name} defeats #{loser_name}"}
    let!(:defeats_txt_multiple) {"#{defeats_txt} 5 times"}

    context 'rejects a request ' do
      it 'token is invalid' do
        post :create_from_txt, params: {token: "invalid"}

        expect(response).to have_http_status(:unauthorized)
      end

      it 'winner does not exist' do
        post :create_from_txt, params: {token: token, text: "John defeats #{loser_name}"}

        expect(response).to have_http_status(:success)
        expect_json(text: "winner can not be found")
      end

      it 'loser does not exist' do
        post :create_from_txt, params: {token: token, text: "#{winner_name} defeats John"}

        expect(response).to have_http_status(:success)
        expect_json(text: "loser can not be found")
      end
    end

    context 'request is valid' do

      it 'creates result' do
        post :create_from_txt, params: {token: token, text: defeats_txt}

        expect(response).to have_http_status(:success)
        expect(Result.all.count).to eql(1)

        result = Result.first
        expect(result.winners.first).to eql(winner)
        expect(result.losers.first).to eql(loser)
      end

      it 'creates result multiple times' do
        post :create_from_txt, params: {token: token, text: defeats_txt_multiple}

        expect(response).to have_http_status(:success)

        expect(Result.all.count).to eql(5)
      end
    end
  end
end