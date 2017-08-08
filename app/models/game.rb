class Game < ActiveRecord::Base

  default_scope { order("updated_at DESC") }

  has_many :ratings, dependent: :destroy
  has_many :results, dependent: :destroy

  RATER_MAPPINGS = {
    "elo" => Rater::EloRater.new,
    "trueskill" => Rater::TrueSkillRater.new
  }

  validates :name, presence: true
  validates :rating_type, inclusion: { in: RATER_MAPPINGS.keys, message: "must be a valid rating type" }
  validate do |game|
    if game.rater
      game.rater.validate_game game
    end
  end

  validates :min_number_of_teams, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :max_number_of_teams, numericality: { only_integer: true, allow_nil: true }
  validate do |game|
    if game.min_number_of_teams && game.max_number_of_teams && game.min_number_of_teams > game.max_number_of_teams
      game.errors.add(:max_number_of_teams, "cannot be less than the minimum")
    end
  end

  validates :min_number_of_players_per_team, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :max_number_of_players_per_team, numericality: { only_integer: true, allow_nil: true }
  validate do |game|
    if game.min_number_of_players_per_team && game.max_number_of_players_per_team && game.min_number_of_players_per_team > game.max_number_of_players_per_team
      game.errors.add(:max_number_of_teams, "cannot be less than the minimum")
    end
  end

  validate do |game|
    if game.rating_type_was && game.rating_type_changed?
      game.errors.add(:rating_type, "cannot be changed")
    end
  end

  validates :allow_ties, inclusion: { in: [true, false], message: "must be selected" }

  def self.default
    Game.first
  end

  def all_ratings
    ratings.order(value: :desc)
  end

  def all_ratings_with_active_players
    all_ratings.select {|rating| rating.player.is_active?}
  end

  def all_ratings_with_players_active_today
    all_ratings.select {|rating| rating.player.is_active_today?}.sort_by{|rating| -rating.player.win_loss_ratio_for_today(self)}
  end

  def as_json(options = {})
    {
      name: name,
      ratings: top_ratings.map(&:as_json),
      results: recent_results.map(&:as_json),
    }
  end

  def players
    ratings.map(&:player)
  end

  def involves_player?(player)
    ratings.any? { |r| r.player == player }
  end

  def recent_results
    results.order("created_at DESC").limit(10)
  end

  def top_ratings
    ratings.order("value DESC").limit(5)
  end

  def rater
    RATER_MAPPINGS[rating_type]
  end

  def recalculate_ratings!
    RatingHistoryEvent.joins(:rating).where(ratings: {game_id: self.id}).destroy_all
    Rating.where(game_id: self.id).destroy_all

    results.order("id ASC").all.each do |result|
      rater.update_ratings self, result.teams.order("rank ASC")
    end
  end

  def self.full_leaderboard
    self.default.all_ratings
  end

  def self.full_leaderboard_as_string
    self.full_leaderboard.enum_for(:each_with_index).collect {|r, i| "#{i+1}. #{r.player.as_string}"}.join("\n")
  end

  def self.leaderboard
    self.default.all_ratings_with_active_players
  end

  def self.leaderboard_as_string
    self.leaderboard.enum_for(:each_with_index).collect {|r, i| "#{i+1}. #{r.player.as_string}"}.join("\n")
  end

  def self.leaderboard_as_slack_attachments
    self.full_leaderboard.enum_for(:each_with_index).collect {|r, i| r.player.create_slack_message_attachment(i)}
  end
end
