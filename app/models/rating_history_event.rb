class RatingHistoryEvent < ActiveRecord::Base
  belongs_to :rating
  scope :events, -> (player, game) do
    includes(:rating)
    .where(ratings: { player_id: player, game_id: game })
  end

  def self.rating_after(player, result)
    associated_rating_history_events(player, result).first().value
  end

  def self.rating_before(player, result)
    events = associated_rating_history_events(player, result)
    return Rater::EloRater::DefaultValue if events.count == 1
    return events.second().value
  end

  def self.associated_rating_history_events(player, result)
    RatingHistoryEvent.joins(:rating)
        .where('rating_history_events.created_at <= ? and ratings.player_id = ?', result.created_at, player.id)
        .order('rating_history_events.created_at desc')
  end

end
