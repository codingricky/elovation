class AddQuotesTable < ActiveRecord::Migration[5.0]
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
                 "He lives near me. Wants to hang out. I should invite him over to play tt",
                 "I think your algorithm needs more data for the calculation. Like number of faulty serves and taper off with more challenges/fatigue. All of it offset by likeliness to troll",
                 "And colors should be based on ELO",
                 "It should blink to indicate that you are close to changing ELO",
                 "Where i lack in points, i offset it with Troll skills",
                 "CDD, colour driven development"]

  def up
    create_table :quotes do |t|
      t.string :quote, null: false

      t.timestamps
    end

    TONY_QUOTES.each do |quote|
      Quote.create(quote: quote)
    end

  end

  def down
  end
end
