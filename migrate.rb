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
    t.float :first_line_average
    t.float :third_line_average
    t.float :fourth_line_average
    t.float :first_pair_average
    t.float :second_pair_average
    t.float :third_pair_average
    t.float :goalie_average
    t.float :first_line_above_repl
    t.float :third_line_above_repl
    t.float :fourth_line_above_repl
    t.float :first_pair_above_repl
    t.float :second_pair_above_repl
    t.float :third_pair_above_repl
    t.float :goalie_above_repl
    t.integer :role
    t.float :points_above_repl
    t.float :aav
    t.float :estoi
    t.float :pptoi
    t.float :shtoi
    t.string :year
    t.string :team
  end

  create_table :records, if_not_exists: true do |t|
    t.integer :cache_id
    t.integer :record_type
    t.text :store
  end

end