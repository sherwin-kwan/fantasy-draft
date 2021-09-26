require "dotenv/load"
require "active_record"

ActiveRecord::Base.establish_connection({
  adapter: ENV["ADAPTER"],
  database: "fantasy_hockey",
  host: "localhost",
  port: 5432,
  username: ENV["USERNAME"],
  password: ENV["PASSWORD"]
})

ActiveRecord::Schema.define do

  create_table :players, if_not_exists: true do |t|
    t.string :first_name
    t.string :last_name
    t.integer :nhl_id
    t.integer :pos
    t.integer :gp
    t.float :toi
    t.float :goals
    t.float :assists
    t.float :shots
    t.float :blocks
    t.float :hits
    t.float :shp
    t.float :tk
    t.float :gv
    t.float :overtime_goals
    t.float :shootout_goals
    t.float :hat_trick
    t.float :plus_minus
    t.float :fow
    t.float :fol
    t.float :wins
    t.float :shutouts
    t.float :ga
    t.float :sv
  end

  change_table :players do |t|
    t.float :aav, if_not_exists: true
  end

  change_table :players do |t|
    t.float :estoi, if_not_exists: true
    t.float :pptoi, if_not_exists: true
    t.float :shtoi, if_not_exists: true
  end

  create_table :records, if_not_exists: true do |t|
    t.integer :cache_id
    t.integer :record_type
    t.text :store
  end

  change_table :players do |t|
    t.float :first_line_average, if_not_exists: true
    t.float :third_line_average, if_not_exists: true
    t.float :fourth_line_average, if_not_exists: true
    t.float :first_pair_average, if_not_exists: true
    t.float :second_pair_average, if_not_exists: true
    t.float :third_pair_average, if_not_exists: true
    t.float :goalie_average, if_not_exists: true
    t.float :first_line_above_repl, if_not_exists: true
    t.float :third_line_above_repl, if_not_exists: true
    t.float :fourth_line_above_repl, if_not_exists: true
    t.float :first_pair_above_repl, if_not_exists: true
    t.float :second_pair_above_repl, if_not_exists: true
    t.float :third_pair_above_repl, if_not_exists: true
    t.float :goalie_above_repl, if_not_exists: true
    t.integer :role, if_not_exists: true
    t.float :points_above_repl, if_not_exists: true
  end

  change_table :players do |t|
    t.string :team, if_not_exists: true
  end

end