namespace :migrate do

  task data: :environment do
    connection = Judgement::Player.connection
    connection.disable_referential_integrity() do
      Judgement::Player.delete_all
      Judgement::Rating.delete_all
      Judgement::Result.delete_all

      Player.all.each do |p|
        unless p.rating
          puts "skipping #{p.name} cause they don't have a rating"
        else
          new_player = Judgement::Player.new
          new_player.name = p.name
          new_player.email = p.email
          new_player.color = p.color
          user = User.find_by_email(p.email)
          new_player.slack_id = user.slack_id
          new_player.inserted_at = DateTime.now
          new_player.updated_at = DateTime.now

          new_player.rating = Judgement::Rating.new
          new_player.rating.value = p.rating.value
          new_player.rating.inserted_at = DateTime.now
          new_player.rating.updated_at = DateTime.now

          new_player.save!
          new_player.rating.player = new_player
          new_player.rating.save!

          new_player.rating_id = new_player.rating.id
          new_player.save!
          puts "migrated #{p.name}"
        end
      end

      Result.all.each do |r|
        winner = Judgement::Player.find_by_email(r.winner.email)
        loser = Judgement::Player.find_by_email(r.loser.email)

        new_result = Judgement::Result.new
        new_result.winner_id = winner.id
        new_result.loser_id = loser.id
        new_result.winner_rating_before = r.winner_points_before
        new_result.winner_rating_after = r.winner_points_after

        new_result.loser_rating_before = r.loser_points_before
        new_result.loser_rating_after = r.loser_points_after

        new_result.inserted_at = r.created_at
        new_result.updated_at = r.updated_at
        new_result.save!

        puts "migrated #{r.inspect}"
      end

      Quote.all.each do |q|
        new_quote = Judgement::Quote.new
        user = User.find_by_id(q.user_id)
        new_player = Judgement::Player.find_by_email(user.email)
        if new_player
          new_quote.player_id = new_player.id
          new_quote.quote = q.quote
          new_quote.inserted_at = q.created_at
          new_quote.updated_at = q.updated_at
          new_quote.save!

          puts "migrated #{new_quote.inspect}"
        end
      end
    end
  end
end
