# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170807013151) do

  create_table "games", force: :cascade do |t|
    t.string   "name",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rating_type"
    t.integer  "min_number_of_teams"
    t.integer  "max_number_of_teams"
    t.integer  "min_number_of_players_per_team"
    t.integer  "max_number_of_players_per_team"
    t.boolean  "allow_ties"
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "color"
  end

  create_table "players_teams", force: :cascade do |t|
    t.integer "player_id"
    t.integer "team_id"
  end

  create_table "rating_history_events", force: :cascade do |t|
    t.integer  "rating_id",           null: false
    t.integer  "value",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
    t.index ["rating_id"], name: "index_rating_history_events_on_rating_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "player_id",           null: false
    t.integer  "game_id",             null: false
    t.integer  "value",               null: false
    t.boolean  "pro",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["player_id"], name: "index_ratings_on_player_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_results_on_game_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "rank"
    t.integer  "result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "api_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
