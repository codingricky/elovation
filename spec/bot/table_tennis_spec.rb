require 'spec_helper'

describe 'Table Tennis' do
  let!(:game) { FactoryGirl.create(:game) }

  let!(:winner) { FactoryGirl.create(:player) }
  let!(:winner_rating) {FactoryGirl.create(:rating, player: winner, game: game)}
  let!(:winner_name) { winner.name.split[0] }

  let!(:loser) { FactoryGirl.create(:player) }
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
    expect(message: "#{SlackRubyBot.config.user} show", user: 'user').to respond_with_slack_message(leaderboard)
  end
end
