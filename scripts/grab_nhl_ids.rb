require "faraday"
require "active_record"

res = Faraday.get("https://statsapi.web.nhl.com/api/v1/teams?expand=team.roster")
data = JSON.parse(res.body)
players = []
data["teams"].each do |team|
  players_on_team = team["roster"]["roster"].map do |person|
    { first_name: person["person"]["fullName"].split(" ").first,
     last_name: person["person"]["fullName"].split(" ").slice(1..-1).join(" "),
     nhl_id: person["person"]["id"] }
  end
  players.concat(players_on_team)
end
Player.where(nhl_id: nil).each do |player|
  try_player = players.filter { |pl| pl[:first_name].downcase == player.first_name.downcase && pl[:last_name].downcase == player.last_name.downcase }&.first
  # Handle players with variant first names (e.g. "Mitch" vs. "Mitchell") - if there's only one player with that last name it's not ambiguous
  if !try_player
    try_again = players.filter { |pl| pl[:last_name] == player.last_name }
    try_player = try_again.first if try_again.length == 1
  end
  player.nhl_id = try_player[:nhl_id] if try_player
  player.save
end
