require 'spec_helper'

describe 'Table Tennis' do
  let!(:game) { FactoryGirl.create(:game) }

  let!(:winner) { FactoryGirl.create(:player, name: "John") }
  let!(:winner_rating) {FactoryGirl.create(:rating, player: winner, game: game)}
  let!(:winner_name) { winner.name.split[0] }

  let!(:loser) { FactoryGirl.create(:player, name: "Garry") }
  let!(:loser_rating) {FactoryGirl.create(:rating, player: loser, game: game)}
  let!(:loser_name) { loser.name.split[0] }

  let!(:defeats_txt) {"#{winner_name} defeats #{loser_name}"}
  let!(:defeats_txt_multiple) {"#{defeats_txt} 5 times"}

  it "show the leaderboard" do
    # 20 games to make players active
    1.upto(20) do
      FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [winner]),
                                                      FactoryGirl.create(:team, rank: 2, players: [loser])])
    end
    leaderboard = [winner.as_string, loser.as_string].join("\n")
    expect(message: "show", user: 'user').to respond_with_slack_message(leaderboard)
  end

  it 'responds to help' do
    expect(message: 'help', user: 'user').to respond_with_slack_message(TableTennis::HELP)
  end

  describe 'creating results' do
    before do
      @slack_message = double("slack").as_null_object
      allow(@slack_message).to receive(:message).and_return("message")
      allow(SlackMessage).to receive(:new).and_return(@slack_message)
      allow(SlackService).to receive(:notify)
    end

    it 'creates one result' do
      expect(message: defeats_txt, user: 'user').to respond_with_slack_message(@slack_message.message)

      expect(Result.all.count).to eql(1)
      result = Result.first
      expect(result.winners.first).to eql(winner)
      expect(result.losers.first).to eql(loser)
    end

    it 'creates multiple results' do
      expect(message: defeats_txt_multiple, user: 'user').to respond_with_slack_message(@slack_message.message)
      expect(Result.all.count).to eql(5)
    end

    it 'does not create a result when winner not found' do
      expect(message: "NOTANAME defeats #{loser_name}", user: 'user').to respond_with_slack_message("winner can not be found")
      expect(Result.all.count).to eql(0)
    end
  end



end
