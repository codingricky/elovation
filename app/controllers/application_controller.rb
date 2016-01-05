class ApplicationController < ActionController::Base
  protect_from_forgery

  def chart_data(game)
    players = Player.all.includes(ratings: :history_events).where(ratings: { game: game })

    player_to_days = Hash.new
    every_day = Set.new
    players.each do |player|
      day_to_event = Hash.new
      RatingHistoryEvent.events(player, game).each do |event|
        day_to_event[event.created_at.to_date.to_s] = event.value
        every_day.add(event.created_at.to_date.to_s)
      end
      player_to_days[player.name] = day_to_event
    end

    players.each do |player|
      last_rating = nil
      every_day.to_a.sort.each_with_index do |day, i|
        last_rating = player_to_days[player.name].fetch(day, last_rating)
        player_to_days[player.name][day] = last_rating
      end
    end

    players.map do |player|
      {:name => player.name, :data => player_to_days[player.name].to_a}
    end
  end
end
