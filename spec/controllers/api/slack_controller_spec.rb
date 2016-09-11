require "spec_helper"

describe Api::SlackController do

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
        post :slack, params: {token: "invalid"}

        expect(response).to have_http_status(:unauthorized)
      end

      it 'winner does not exist' do
        post :slack, params: {token: token, text: "John defeats #{loser_name}"}

        expect(response).to have_http_status(:success)
        expect_json(text: "winner can not be found")
      end

      it 'loser does not exist' do
        post :slack, params: {token: token, text: "#{winner_name} defeats John"}

        expect(response).to have_http_status(:success)
        expect_json(text: "loser can not be found")
      end
    end

    context 'request is valid' do
      before do
        @slack_message = double("slack").as_null_object
        allow(@slack_message).to receive(:message).and_return("message")
        allow(SlackMessage).to receive(:new).and_return(@slack_message)
        allow(SlackService).to receive(:notify)
      end

      it 'creates result' do
        post :slack, params: {token: token, text: defeats_txt}

        expect(response).to have_http_status(:success)
        expect(Result.all.count).to eql(1)

        result = Result.first
        expect(result.winners.first).to eql(winner)
        expect(result.losers.first).to eql(loser)

        expect_json(text: @slack_message.message)

      end

      it 'creates result multiple times' do
        post :slack, params: {token: token, text: defeats_txt_multiple}

        expect(response).to have_http_status(:success)

        expect(Result.all.count).to eql(5)

        expect_json(text: @slack_message.message)
      end
    end
  end


end