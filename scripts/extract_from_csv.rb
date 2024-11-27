require "csv"
require "./models/player.rb"
require "pry"

source_file = File.join(File.dirname(__FILE__), "../projections/projections_20241029.csv")
raw_data = CSV.parse(File.read(source_file), headers: true)

def parse_position(str)
  positions = str.split(",").map do |abbr|
    abbr = abbr.strip
    if ["C", "LW", "RW"].include? abbr
      "F"
    elsif ["LD", "RD"].include? abbr
      "D"
    else
      abbr
    end
  end
  positions = positions.uniq
  if positions.length > 1
    "rover"
  elsif positions.first == "F"
    "forward"
  elsif positions.first == "D"
    "defence"
  elsif positions.first == "G"
    "goalie"
  else
    raise "There is no valid position"
  end
end

def process_doms_data(player_data, overwrite)
  first_name = player_data["NAME"].split(" ").first
  last_name = player_data["NAME"].split(" ").slice(1..-1).join(" ")
  # If the player already exists in the db, overwrite them unless asked not to
  try_player = Player.where(first_name: first_name).where(last_name: last_name).first
  return if try_player && !overwrite || !player_data["POS"]
  output = try_player || Player.new
  output.first_name = first_name
  output.last_name = last_name
  output.team = player_data["TEAM"]
  output.pos = parse_position(player_data["POS"])
  output.gp = player_data["GP"]
  output.toi = player_data["TOI"]
  if output.pos == "goalie"
    output.wins = player_data["W"]
    output.shutouts = player_data["SO"]
    output.sv = player_data["SV"]
    output.ga = player_data["GA"]
  else
    output.goals = player_data["G"]
    output.assists = player_data["A"]
    output.shots = player_data["SOG"]
    output.blocks = player_data["BLK"]
    output.hits = player_data["HIT"]
    output.plus_minus = player_data["+/-"]
    output.fow = player_data["FOW"]
    output.fol = player_data["FOL"]
    output.shp = player_data["SHP"]
  end
  output
end

raw_data.each do |row|
  player = process_doms_data(row, true)
  player.year = 2024
  player.save if player
end
