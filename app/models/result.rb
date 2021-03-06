require 'csv'

class Result < ActiveRecord::Base
  has_many :teams
  belongs_to :game, touch: true

  validates :game, presence: true
  scope :most_recent_first, -> { order created_at: :desc }
  scope :for_game, -> (game) { where(game_id: game.id) }

  validate do |result|
    if result.winners.empty?
      result.errors.add(:teams, "must have a winner")
    end

    if result.players.size != players.uniq.size
      result.errors.add(:teams, "must have unique players")
    end

    if result.teams.size < result.game.min_number_of_teams
      result.errors.add(:teams, "must have at least #{result.game.min_number_of_teams} teams")
    end

    if result.game.max_number_of_teams && result.teams.size > result.game.max_number_of_teams
      result.errors.add(:teams, "must have at most #{result.game.max_number_of_teams} teams")
    end

    if result.teams.any?{|team| team.players.size < result.game.min_number_of_players_per_team}
      result.errors.add(:teams, "must have at least #{result.game.min_number_of_players_per_team} players per team")
    end

    if result.game.max_number_of_players_per_team && result.teams.any?{|team| team.players.size > result.game.max_number_of_players_per_team}
      result.errors.add(:teams, "must have at most #{result.game.max_number_of_players_per_team} players per team")
    end

    if !result.game.allow_ties && result.teams.map(&:rank).uniq.size != result.teams.size
      result.errors.add(:teams, "game does not allow ties")
    end
  end

  def players
    teams.map(&:players).flatten
  end

  def winners
    teams.select{ |team| team.rank == Team::FIRST_PLACE_RANK }.map(&:players).flatten
  end

  def losers
    teams.select{ |team| team.rank != Team::FIRST_PLACE_RANK }.map(&:players).flatten
  end

  def tie?
    teams.count == teams.winners.count
  end

  def winner
    winners.first
  end

  def loser
    losers.first
  end

  def is_winner?(player)
    winner == player
  end

  def points_difference(player)
    return winner_points_difference if player == winner
    return loser_points_difference if player == loser
    return 0
  end

  def loser_points_difference
    loser_points_after - loser_points_before
  end

  def winner_points_difference
    winner_points_after - winner_points_before
  end

  def winner_points_after
    RatingHistoryEvent.rating_after(winner, self)
  end

  def winner_points_before
    RatingHistoryEvent.rating_before(winner, self)
  end

  def loser_points_after
    RatingHistoryEvent.rating_after(loser, self)
  end

  def loser_points_before
    RatingHistoryEvent.rating_before(loser, self)
  end

  def as_json(options = {})
    {
      winner: winners.first.name,
      loser: losers.first.name,
      created_at: created_at.utc.to_s
    }
  end

  def most_recent?
    teams.all? do |team|
      team.players.all? do |player|
        player.results.where(game_id: game.id).order("created_at DESC").first == self
      end
    end
  end

  def day
    created_at.strftime("%A")
  end

  def to_hash
    {winner: result.winner.name, loser: result.loser.name, day: result.day}
  end

  def self.to_csv
    header = %w{winner loser day}
    CSV.generate(headers: true) do |csv|
      csv << header
      all.each do |result|
        csv << [result.winner.name, result.loser.name, result.day]
      end
    end
  end
end
