# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Game.create(name: 'Table Tennis', rating_type: 'trueskill', min_number_of_teams: 2, max_number_of_teams: 2, min_number_of_players_per_team: 1, max_number_of_players_per_team: 1, allow_ties: false)