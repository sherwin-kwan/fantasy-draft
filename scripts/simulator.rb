$names = %w(Alex Billy Ellery Jason Joey Nathaniel Omar Sherwin)
# $average = [211.4, 213.3, 193.3, 194.0, 202.8, 184.2, 201.3, 207.4]
# $current = [9216, 8792, 8138, 8081, 9148, 7582, 8243, 8650]
# $sd = 60
# $gl = 41
$average = [212, 60, 190, 185, 50, 180, 205, 205]
$current = [17900, 17460, 15800, 15630, 17440, 14340, 16725, 16980]
$sd = 60
$gl = 2
$results = Hash.new
$scores_archive = []

# https://stackoverflow.com/questions/5825680/code-to-generate-gaussian-normally-distributed-random-numbers-in-ruby
def gaussian(mean, sd)
  theta = 2 * Math::PI * rand
  rho = Math.sqrt(-2 * Math.log(1 - rand))
  scale = sd * rho
  return mean + scale * Math.cos(theta)
end

def simulate
  scores = (0..7).map do |n|
    average = gaussian($average[n], 3)
    [$names[n], gaussian(average * $gl, $sd * Math.sqrt($gl)) + $current[n]]
  end
  scores.sort!{|a, b| b.last <=> a.last}
  $scores_archive << scores
  scores.each_with_index do |tuple, ind|
    $results[tuple.first][ind] += 1
  end
end

$names.each do |name|
  $results[name] = Array.new(8){0}
end

100000.times{simulate}
p $results
res = $results.map{|k, v| [k, v.first(3).sum / 1000.0]}.sort{|a, b| b.last <=> a.last}.to_h
pp res
res = $results.map{|k, v| [k, v.first / 1000.0]}.sort{|a, b| b.last <=> a.last}.to_h
pp res