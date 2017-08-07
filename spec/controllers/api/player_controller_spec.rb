require "spec_helper"

describe Api::PlayerController do

  let!(:game) { FactoryGirl.create(:game) }
  let!(:winner) { FactoryGirl.create(:player) }
  let!(:winner_rating) { FactoryGirl.create(:rating, player: winner, game: game) }
  let!(:loser) { FactoryGirl.create(:player) }
  let!(:loser_rating) { FactoryGirl.create(:rating, player: loser, game: game) }
  let(:valid_token) { ActionController::HttpAuthentication::Token.encode_credentials('valid_token') }

  before do
    request.env['HTTP_AUTHORIZATION'] = valid_token
    allow(User).to receive(:find_by).and_return(double("user"))
  end

  context 'lookup' do
    it 'should return player details' do
      allow(Player).to receive(:with_name).and_return(winner)
      allow(winner).to receive(:ranking).and_return(1)
      allow(winner).to receive(:points).and_return(1000)
      allow(winner).to receive(:color).and_return('green')


      get :lookup, params: {player: winner.name}

      expect_json(points: 1000, ranking: 1, color: 'green   ')
    end

    it 'return an error if not found' do
      allow(Player).to receive(:with_name).and_return(nil)

      get :lookup, params: {player: winner.name}

      expect(response).to have_http_status(:not_found)
    end
  end

end