require "csv"

data1 = CSV.parse(File.read("./export_20211206.csv"), headers: false)
data2 = CSV.parse(File.read("./export.csv"), headers: false)

data_new = data2.each do |player|
  corresponding_player = data1.filter{|pl| pl[0] == player[0]}.first
  if corresponding_player && corresponding_player[2]
    player[4] = corresponding_player[4]
    player[5] = corresponding_player[2]
    player[6] = player[2].to_f - player[5].to_f
  end
  player[5] ||= 0
  player[6] ||= 0
end

data_new.sort{|a, b| b[2] <=> a[2]}.each do |pl|
  p pl
end

CSV.open("export_enhanced.csv", "w") do |csv|
  data_new.each do |player|
    csv.add_row player
  end
end