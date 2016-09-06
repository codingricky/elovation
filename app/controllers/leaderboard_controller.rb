class LeaderboardController < ApplicationController

  def show
    @players = Player.all.sort_by(&:name)
    @games = Game.all
  end

  def show_image
    url = url_for(controller: 'leaderboard', action: 'show')
    image = Gastly.screenshot(url)
    captured_image = image.capture
    send_data captured_image.image.to_blob, type: 'image/png', disposition: 'inline'
  end
end
