require "nokogiri"
require "faraday"
require "active_record"

# res = Faraday.get("https://statsapi.web.nhl.com/api/v1/teams")
# teams_data = JSON.parse(res.body)

# teams = []
# teams_data["teams"].each do |team|
#   teams.push(team["teamName"])
# end

counter = 0
Player.all.each do |player|
  player_url = "https://www.capfriendly.com/players/#{player.capfriendly_case}"
  begin
    res = Faraday.get(player_url)
  rescue URI::InvalidURIError => e # Handling players with accents
    puts "Invalid URL found for player: " + player.capfriendly_case
    next
  end
  doc = Nokogiri::HTML(res.body)
  # Scrape for "Cap Hit: $8,000,000" on the player's page
  caphit_string = doc.css('div.ofh > div.c').first
  if caphit_string
    player.aav = caphit_string.text.split("$").last.gsub(",", "").to_i
    player.save
  end
  counter += 1
  if counter % 20 == 0
    puts "Scraped #{counter} players"
  end
end

