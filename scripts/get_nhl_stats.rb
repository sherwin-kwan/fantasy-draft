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
    res = Faraday.get("https://api.nhle.com/stats/rest/en/skater/realtime?isAggregate=false&isGame=false&sort=[{%22property%22:%22playerId%22,%22direction%22:%22ASC%22}]&start=#{(i * 100).to_s}&limit=100&factCayenneExp=gamesPlayed%3E=1&cayenneExp=gameTypeId=2%20and%20seasonId%3C=20242025%20and%20seasonId%3E=20242025")
    data = res.body
    Record.create({cache_id: i, record_type: "real_time", store: data})
  end
  data = JSON.parse(data)
  data["data"].each do |pl|
    binding.pry if pl["playerId"] == "8476468"
    player = Player.where(nhl_id: pl["playerId"].to_i).first
    # Correct for issues e.g. if a player can't be found in NHL database due to being sent to minors or on injured reserve
    if !player
      player = Player.where(first_name: pl["skaterFullName"].split(" ")[0]).where(last_name: pl["skaterFullName"].split(" ")[1..-1].join(" ")).first
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

# Ice time

(0...10).each do |i|
  if Record.where(cache_id: i).where(record_type: "toi").count > 0
    data = Record.find_by(cache_id: i, record_type: "toi").store
  else
    res = Faraday.get("https://api.nhle.com/stats/rest/en/skater/timeonice?isAggregate=false&isGame=false&sort=[{%22property%22:%22timeOnIce%22,%22direction%22:%22DESC%22},{%22property%22:%22playerId%22,%22direction%22:%22ASC%22}]&start=0&limit=100&cayenneExp=gameTypeId=2%20and%20seasonId%3C=20242025%20and%20seasonId%3E=20242025")
    data = res.body
    Record.create({cache_id: i, record_type: "toi", store: data})
  end
  data = JSON.parse(data)
  data["data"].each do |pl|
    player = Player.where(nhl_id: pl["playerId"].to_i).first
    # Correct for issues e.g. if a player can't be found in NHL database due to being sent to minors or on injured reserve
    if !player
      player = Player.where(first_name: pl["skaterFullName"].split(" ")[0]).where(last_name: pl["skaterFullName"].split(" ")[1..-1].join(" ")).first
      player.nhl_id = pl["playerId"] if player
    end
    if player
      player.toi ||= pl["timeOnIcePerGame"] / 60 # For Dobber which has no TOI
      player.pptoi = pl["ppTimeOnIcePerGame"] / 60
      player.shtoi = pl["shTimeOnIcePerGame"] / 60
      player.estoi = player.toi - player.pptoi - player.shtoi
      player.save
    else
      puts "Unable to find NHL player #{pl["skaterFullName"]} - #{pl["playerId"]} in spreadsheet"
    end
  end
end

Record.where(record_type: "faceoffs").destroy_all
# Get faceoffs
(0...10).each do |i|
  data = nil
  if Record.where(cache_id: i).where(record_type: "faceoffs").count > 0
    data = Record.find_by(cache_id: i, record_type: "faceoffs").store
  else
    res = Faraday.get("https://api.nhle.com/stats/rest/en/skater/faceoffwins?isAggregate=false&isGame=false&sort=[{%22property%22:%22playerId%22,%22direction%22:%22ASC%22}]&start=#{(i * 100).to_s}&limit=100&factCayenneExp=gamesPlayed%3E=1&cayenneExp=gameTypeId=2%20and%20seasonId%3C=20242025%20and%20seasonId%3E=20242025")
    data = res.body
    Record.create({cache_id: i, record_type: "faceoffs", store: data})
  end
  data = JSON.parse(data)
  data["data"].each do |pl|
    player = Player.where(nhl_id: pl["playerId"].to_i).first
    # Correct for issues e.g. if a player can't be found in NHL database due to being sent to minors or on injured reserve
    if !player
      player = Player.where(first_name: pl["skaterFullName"].split(" ")[0]).where(last_name: pl["skaterFullName"].split(" ")[1..-1].join(" ")).first
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
