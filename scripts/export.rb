require "active_record"
require "csv"
require "./models/player"

player_rankings = Player.where('points_above_repl > ?', -0.1).select([:first_name, :last_name, :team]).order('points_above_repl DESC')
CSV.open("export.csv", "w") do |csv|
  player_rankings.each do |player|
    csv.add_row ["#{player.first_name} #{player.last_name}", player.team]
  end
end