require "csv"
require "pry"

data1 = CSV.parse(File.read("./2024/pool_20250301.csv"), headers: false)
data2 = CSV.parse(File.read("export.csv"), headers: false)

data_new = data2.each do |player|
  corresponding_player = data1.filter{|pl| pl[0] == player[0]}.first
  if corresponding_player && corresponding_player[2]
    player[6] ||= corresponding_player[6]
    player[7] = corresponding_player[2]
    player[8] = player[2].to_f - player[7].to_f
  end
  player[7] ||= 0
  player[8] ||= 0
end

data_new.sort{|a, b| b[8].to_f <=> a[8].to_f}.each do |pl|
  p pl
end

CSV.open("export_enhanced.csv", "w") do |csv|
  data_new.each do |player|
    csv.add_row player
  end
end