# Grabbing last year's stats for TK, BK, and SHG
require "faraday"
require "active_record"
require "./models/record.rb"
require "pry"

class String
  def parse_interval
    int = self.strip
    minutes = int.split(":").first.to_i
    seconds = int.split(":").last.to_i
    return minutes + seconds.to_f / 60
  end
end

# Find real-time stats (TK, GV)
(0...10).each do |i|
  data = nil
  if Record.where(cache_id: i).where(record_type: "real_time").count > 0
    data = Record.where(cache_id: i).first.store
  else
    res = Faraday.get("https://api.nhle.com/stats/rest/en/skater/realtime?isAggregate=false&isGame=false&sort=[{%22property%22:%22playerId%22,%22direction%22:%22ASC%22}]&start=#{(i * 100).to_s}&limit=100&factCayenneExp=gamesPlayed%3E=1&cayenneExp=gameTypeId=2%20and%20seasonId%3C=20212022%20and%20seasonId%3E=20212022")
    data = res.body
    Record.create({cache_id: i, record_type: 0, store: data})
  end
  data = JSON.parse(data)
  data["data"].each do |pl|
    player = Player.where(nhl_id: pl["playerId"].to_i).first
    # Correct for issues e.g. if a player can't be found in NHL database due to being sent to minors or on injured reserve
    if !player
      player = Player.where(first_name: pl["skaterFullName"].split(" ")[0]).where(last_name: pl["skaterFullName"].split(" ")[1]).first
      player.nhl_id = pl["playerId"] if player
    end
    if player
      player.toi ||= pl["timeOnIcePerGame"] / 60 # For Dobber which has no TOI
      player.tk = pl["gamesPlayed"] < 10 ? 0 : (player.toi / (pl["timeOnIcePerGame"] / 60) * (pl["takeaways"].to_f / pl["gamesPlayed"].to_i)).round(2)
      player.gv = pl["gamesPlayed"] < 10 ? 0 : (player.toi / (pl["timeOnIcePerGame"] / 60) * (pl["giveaways"].to_f / pl["gamesPlayed"].to_i)).round(2)
      player.save
    else
      puts "Unable to find NHL player #{pl["skaterFullName"]} - #{pl["playerId"]} in spreadsheet"
    end
  end
end

# Ice time and shorthanded points
Player.where('nhl_id IS NOT NULL and shp IS NULL').find_each do |player|
  res = Faraday.get("https://statsapi.web.nhl.com/api/v1/people/#{player.nhl_id}/stats?stats=statsSingleSeason&season=20212022")
  data = JSON.parse(res.body)
  stats = data["stats"].first["splits"]&.first&.[]("stat")
  if stats
    player.pptoi ||= stats["powerPlayTimeOnIcePerGame"]&.parse_interval
    player.shtoi = stats["shortHandedTimeOnIcePerGame"]&.parse_interval
    # player.estoi ||= stats["evenTimeOnIcePerGame"]&.parse_interval
    if player.toi && player.pptoi && player.shtoi
      player.estoi = player.toi - player.pptoi - player.shtoi
    end
    player.shp = stats["shortHandedPoints"].to_f / stats["games"]
    player.save
  end
end

Record.where(record_type: "faceoffs").destroy_all
# Get faceoffs
(0...10).each do |i|
  data = nil
  if Record.where(cache_id: i).where(record_type: "faceoffs").count > 0
    data = Record.where(cache_id: i).first.store
  else
    res = Faraday.get("https://api.nhle.com/stats/rest/en/skater/faceoffwins?isAggregate=false&isGame=false&sort=[{%22property%22:%22playerId%22,%22direction%22:%22ASC%22}]&start=#{(i * 100).to_s}&limit=100&factCayenneExp=gamesPlayed%3E=1&cayenneExp=gameTypeId=2%20and%20seasonId%3C=20212022%20and%20seasonId%3E=20212022")
    data = res.body
    Record.create({cache_id: i, record_type: 2, store: data})
  end
  data = JSON.parse(data)
  data["data"].each do |pl|
    player = Player.where(nhl_id: pl["playerId"].to_i).first
    # Correct for issues e.g. if a player can't be found in NHL database due to being sent to minors or on injured reserve
    if !player
      player = Player.where(first_name: pl["skaterFullName"].split(" ")[0]).where(last_name: pl["skaterFullName"].split(" ")[1]).first
      player.nhl_id = pl["playerId"] if player
    end
    if player
      player.fow ||= pl["gamesPlayed"] < 10 ? 0 : (pl["totalFaceoffWins"].to_f / pl["gamesPlayed"].to_i).round(2)
      player.fol ||= pl["gamesPlayed"] < 10 ? 0 : (pl["totalFaceoffLosses"].to_f / pl["gamesPlayed"].to_i).round(2)
      player.save
    else
      puts "Unable to find player #{pl["skaterFullName"]} - #{pl["playerId"]} in spreadsheet"
    end
  end
end
