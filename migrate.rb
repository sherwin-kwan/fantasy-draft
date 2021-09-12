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

end