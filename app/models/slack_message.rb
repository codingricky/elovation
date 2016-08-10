class SlackMessage

  def initialize(winner_id, loser_id, game, multiplier)
    @winner_id = winner_id
    @loser_id = loser_id
    @game = game
    @winner_rating_before = Rating.find_by(player_id: @winner_id, game_id: @game.id).value
    @loser_rating_before = Rating.find_by(player_id: @loser_id, game_id: @game.id).value
    @multiplier = multiplier
  end

  def save_after_rating
    @winner_rating_after =  Rating.find_by(player_id: @winner_id, game_id: @game.id).value
    @loser_rating_after =  Rating.find_by(player_id: @loser_id, game_id: @game.id).value
  end


  def message
    ":table_tennis_paddle_and_ball: #{winner_message} defeated #{loser_message} #{multiplier_message} #{Faker::SlackEmoji.celebration}"
  end

  private

  def winner_message
    "*#{winner_name}* (~#{@winner_rating_before}~ - #{@winner_rating_after})"
  end

  def loser_message
    "*#{loser_name}* (~#{@loser_rating_before}~ - #{@loser_rating_after})"
  end

  def multiplier_message
    @multiplier > 1 ? "#{@multiplier} times" : ""
  end

  def winner_name
    Player.find(@winner_id).name
  end

  def loser_name
    Player.find(@loser_id).name
  end
end