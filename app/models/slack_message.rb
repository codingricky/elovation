
class SlackMessage

  TONY_QUOTES = ["Holy crap Elliott getting so good now",
                 "nice play bro. Getting on the principle consultant's good side to get better projects",
                 "Dont expose my strategy man",
                 "The next time you get an awesome project, don't forget that you beat me at tt all the time",
                 "Sounds like what you did to me actually. Those were good rounds",
                 "It's extremely satisfying to be able to continuously smash",
                 "I think he's using machine learning to defeat us",
                 "I didn't say it was deep learning",
                 "More like regression",
                 "I thought it was the opposite. The last time Elliott king of the hill'd he got sick after 4 games" ,
                 "we had a dude once that panted from exhaustion after 1 game",
                 "He lives near me. Wants to hang out. I should invite him over to play tt"]

  attr_accessor :winner_rating_after, :winner_rating_before, :loser_rating_before, :loser_rating_after

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
    ":table_tennis_paddle_and_ball: #{winner_message} defeated #{loser_message} #{multiplier_message}" + "\n#{taco_message}"
  end

  def winner_name
    Player.find(@winner_id).name
  end

  def loser_name
    Player.find(@loser_id).name
  end

  def taco_message
    ":tony: says #{random_tony_quote}"
  end

  def random_tony_quote
    TONY_QUOTES.sample
  end

  def winner_message
    "*#{winner_name}* (~#{@winner_rating_before}~ - #{@winner_rating_after})"
  end

  def loser_message
    "*#{loser_name}* (~#{@loser_rating_before}~ - #{@loser_rating_after})"
  end

  def multiplier_message
    @multiplier > 1 ? "#{@multiplier} times" : ""
  end

end
