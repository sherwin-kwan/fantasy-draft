require "faraday"
require "./models/player.rb"
require "active_record"
require "pry"

Player.where(year: nil).destroy_all 

# Get list of all teams's 3-letter abbreviations
res = Faraday.get("https://api.nhle.com/stats/rest/en/team")
data = JSON.parse(res.body)
teams = data["data"].map{_1["triCode"]}
players = []

teams.each do |team|
  puts "doing #{team}"
  res = Faraday.get("https://api-web.nhle.com/v1/roster/#{team}/20262027") # Hard-coded since NHL changed its API to not use "current"
  if res.status != 200
    puts "Team #{team} not found on NHL API for the 2026-27 season #{res.status}" 
    next
  end
  data = JSON.parse(res.body)
  roster = (data["forwards"] + data["defensemen"] + data["goalies"])
  roster.each do |player|
    players << {
      first_name: player["firstName"]["default"],
      last_name: player["lastName"]["default"],
      team: team,
      nhl_id: player["playerId"]
    }
  end
end


Player.where(nhl_id: nil, year: 2026).each do |player|
  try_player = players.filter { |pl| pl[:first_name].downcase == player.first_name.downcase && pl[:last_name].downcase == player.last_name.downcase }&.first
  # Handle players with variant first names (e.g. "Mitch" vs. "Mitchell") - if there's only one player with that last name it's not ambiguous
  if !try_player
    try_again = players.filter { |pl| pl[:last_name] == player.last_name }
    try_player = try_again.first if try_again.length == 1
  end
  player.nhl_id = try_player[:nhl_id] if try_player
  player.team = try_player[:team] if try_player
  player.save
end
