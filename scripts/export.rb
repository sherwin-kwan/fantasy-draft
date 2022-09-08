require "active_record"
require "csv"
require "./models/player"
require "pry"

player_rankings = Player.where('points_above_repl > ?', -1).select([:first_name, :last_name, :team, :role, :points_above_repl, :aav]).order('points_above_repl DESC')
CSV.open("export.csv", "w") do |csv|
  player_rankings.each do |player|
    csv.add_row ["#{player.first_name} #{player.last_name}", player.team, player.points_above_repl, player.role.gsub("_average", ""), player.aav]
  end
end