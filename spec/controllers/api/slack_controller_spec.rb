require "spec_helper"

describe Api::SlackController do

  describe 'slack' do
    let!(:game) { FactoryGirl.create(:game) }

    let!(:winner) { FactoryGirl.create(:player, name: "John") }
    let!(:winner_rating) {FactoryGirl.create(:rating, player: winner, game: game)}
    let!(:winner_name) { winner.name.split[0] }

    let!(:loser) { FactoryGirl.create(:player, name: "Garry") }
    let!(:loser_rating) {FactoryGirl.create(:rating, player: loser, game: game)}
    let!(:loser_name) { loser.name.split[0] }

    let!(:token) { ENV["SLACK_TOKEN"] = "ABC"}
    let!(:defeats_txt) {"#{winner_name} defeats #{loser_name}"}
    let!(:defeats_txt_multiple) {"#{defeats_txt} 5 times"}

    context 'rejects a request ' do
      it 'token is invalid' do
        post :slack, params: {token: "invalid"}

        expect(response).to have_http_status(:unauthorized)
      end

      it 'winner does not exist' do
        post :slack, params: {token: token, text: "NOTANAME defeats #{loser_name}"}

        expect(response).to have_http_status(:success)
        expect_json(text: "winner can not be found")
      end

      it 'loser does not exist' do
        post :slack, params: {token: token, text: "#{winner_name} defeats NOTANAME"}

        expect(response).to have_http_status(:success)
        expect_json(text: "loser can not be found")
      end
    end

    context 'help' do
      it 'should display help' do
        post :slack, params: {token: token, text: "help"}

        expect(response).to have_http_status(:success)
        expect(Result.all.count).to eql(0)
        expect(JSON.parse(response.body)["text"]).to_not be_blank
      end
    end

    context 'show' do
      before do
        # 20 games to make players active
        1.upto(20) do
          FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [winner]),
                                                          FactoryGirl.create(:team, rank: 2, players: [loser])])
        end
      end

      it 'should display leaderboard' do
        post :slack, params: {token: token, text: "show"}

        expect(response).to have_http_status(:success)
        expect_json(text: ['1.' + winner.as_string, '2.' + loser.as_string].join("\n"))
      end
    end

    context 'create result' do
      before do
        @slack_message = double("slack").as_null_object
        allow(@slack_message).to receive(:message).and_return("message")
        allow(SlackMessage).to receive(:new).and_return(@slack_message)
        allow(SlackService).to receive(:notify)
      end

      it 'creates one result' do
        post :slack, params: {token: token, text: defeats_txt}

        expect(response).to have_http_status(:success)
        expect(Result.all.count).to eql(1)

        result = Result.first
        expect(result.winners.first).to eql(winner)
        expect(result.losers.first).to eql(loser)

        expect_json(text: @slack_message.message)
      end

      it 'creates multiple results' do
        post :slack, params: {token: token, text: defeats_txt_multiple}

        expect(response).to have_http_status(:success)
        expect(Result.all.count).to eql(5)
        expect_json(text: @slack_message.message)
      end
    end
  end


end
