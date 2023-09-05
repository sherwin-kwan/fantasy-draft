# This is an iterative method of finding the replacement level of each position

require "./models/player"

class Role
  attr_accessor :spots, :replacement_level, :name

  def initialize(params)
    @name = params[:name]
    @spots = params[:spots]
    @replacement_level = params[:replacement_level]
  end

  def above_repl_key
    self.name.gsub("average", "above_repl")
  end
end

class Player

  NUM_MANAGERS = 8

  def calculate_role_points
    begin
      case self.pos
      when "forward"
        self.tk ||= 0
        self.gv ||= 0
        self.shp ||= 0
        faceoff_score = [0, (self.fow - self.fol) * 0.5].max
        self.first_line_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.shp * 10 + faceoff_score
        self.third_line_average = self.goals * 5 + self.assists * 5 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.shp * 10 + faceoff_score
        self.fourth_line_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.shp * 10 + faceoff_score
        self.first_pair_average = self.second_pair_average = self.third_pair_average = self.goalie_average = -1
        self.save
      when "defence"
        self.tk ||= 0
        self.gv ||= 0
        self.shp ||= 0
        plus_minus_score = self.plus_minus * 2
        self.first_pair_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.hits * 0.5 + self.blocks * 1 + self.tk * 1 - self.gv * 1 + plus_minus_score + self.shp * 10
        self.second_pair_average = self.goals * 6 + self.assists * 6 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + plus_minus_score + self.shp * 10
        self.third_pair_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + plus_minus_score + self.shp * 10
        self.first_line_average = self.third_line_average = self.fourth_line_average = self.goalie_average = -1
        self.save
      when "goalie"
        self.goalie_average = self.sv - self.ga * 7 + self.wins * 5 + self.shutouts * 10
        self.first_pair_average = self.second_pair_average = self.third_pair_average = self.first_line_average = self.third_line_average = self.fourth_line_average = -1
        self.save
      when "rover"
        faceoff_score = [0, (self.fow - self.fol) * 0.5].max
        self.first_line_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.shp * 10 + faceoff_score
        self.third_line_average = self.goals * 5 + self.assists * 5 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.shp * 10 + faceoff_score
        self.fourth_line_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.shp * 10 + faceoff_score
        plus_minus_score = self.plus_minus * 2
        self.first_pair_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.hits * 0.5 + self.blocks * 1 + self.tk * 1 - self.gv * 1 + plus_minus_score + self.shp * 10
        self.second_pair_average = self.goals * 6 + self.assists * 6 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + plus_minus_score + self.shp * 10
        self.third_pair_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + plus_minus_score + self.shp * 10
        self.goalie_average = -1
        self.save
      end
    rescue => e
      puts "Error for player #{self.first_name} #{self.last_name}"
      p e.message
    end
  end

  class << self
    def calculate_role_points
      Player.find_each do |player|
        player.calculate_role_points
        player.save
      end
    end

    def role_positions
      {
        first_line_average: 9,
        third_line_average: 4,
        fourth_line_average: 5,
        first_pair_average: 3,
        second_pair_average: 3,
        third_pair_average: 3,
        goalie_average: 3
      }
    end

    def replacement_level_init
    {
      first_line_average: 9.5,
      third_line_average: 8,
      fourth_line_average: 6,
      first_pair_average: 7.5,
      second_pair_average: 7.5,
      third_pair_average: 7.5,
      goalie_average: 7.5
    }
    end

    def overall_score
      Player.above_repl_array.map{|role| self.send(role)}.max
    end

    # Find the real replacement level for each position
    # Set that replacement level
    # Iterate

    def calculate_ratings(redo_scores = false)
      self.calculate_role_points if redo_scores
      roles_array = []
      # self.roles pulls the roles enum defined in player.rb
      self.roles.map{|role| role[0]}.each do |role|
        the_role = Role.new({name: role, spots: self.role_positions[role.to_sym], replacement_level: self.replacement_level_init[role.to_sym]})
        roles_array.push(the_role)
      end
      100.times do
        Player.all.find_each do |player|
          player.points_above_repl = -100 # Default to drop players to the bottom of the list for positions they don't play
          roles_array.each do |role|
            raw_score = player.send(role.name)
            begin
              score_above_repl = raw_score - role.replacement_level
              if score_above_repl > player.points_above_repl
                player.role = role.name
                player.points_above_repl = score_above_repl
              end
              player.send(role.above_repl_key + "=", raw_score - role.replacement_level)
            rescue => e
              puts "Error calculating points above repl for #{role.name} for #{player.first_name} #{player.last_name}"
            end
          end
          player.save
        end
        if iterate_replacement_levels(roles_array) 
          roles_array = iterate_replacement_levels(roles_array)
        else
          return
        end
      end
    end
    
    def iterate_replacement_levels(roles_array)
      good_enough = true
      roles_array.each do |role|
        players_in_this_role = Player.where(role: role.name).order(points_above_repl: :desc)
        # Let's say there are 4 spots for first line wingers. Then 32 players will be claimed above replacement level for this position. 
        # Find the score of the 33rd player to determine a new guess for replacement level.
        puts "For role #{role.name}, there are #{players_in_this_role.where("points_above_repl > 0").length.to_s} players above replacement"
        if players_in_this_role.length > (NUM_MANAGERS * role.spots + 1)
          deviation = players_in_this_role[NUM_MANAGERS * role.spots].points_above_repl # How many points the replacement level is off from what it "should" be
          next if deviation.abs < 0.02
          if deviation.abs > 0.08
            role.replacement_level = deviation > 0 ? role.replacement_level + 0.02 : role.replacement_level - 0.02
          else
            role.replacement_level += deviation / 4
          end
          good_enough = false
        else
          role.replacement_level -= 0.05
          good_enough = false
        end
        puts "For role #{role.name}, the new replacement level is #{role.replacement_level}"
      end
      return good_enough ? nil : roles_array
    end
  end
end

Player.calculate_ratings(true)
