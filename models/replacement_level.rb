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

  def calculate_role_points
    begin
      case self.pos
      when "forward"
        self.tk ||= 0
        self.gv ||= 0
        self.shp ||= 0
        faceoff_score = (self.fow - self.fol) * 0.5
        self.first_line_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.shp * 10
        self.first_centre_average = self.first_line_average + faceoff_score
        self.third_line_average = self.goals * 5 + self.assists * 5 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.shp * 10
        self.third_centre_average = self.third_line_average + faceoff_score
        self.fourth_line_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.shp * 10
        self.fourth_centre_average = self.fourth_line_average + faceoff_score
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
        self.first_line_average = self.third_line_average = self.fourth_line_average = self.first_centre_average = self.third_centre_average = self.fourth_centre_average = self.goalie_average = -1
        self.save
      when "goalie"
        self.goalie_average = self.sv - self.ga * 7 + self.wins * 5 + self.shutouts * 10
        self.first_pair_average = self.second_pair_average = self.third_pair_average = self.first_line_average = self.third_line_average = self.fourth_line_average = self.first_centre_average = self.third_centre_average = self.fourth_centre_average = -1
        self.save
      when "rover"
        faceoff_score = (self.fow - self.fol) * 0.5
        self.first_line_average = self.goals * 10 + self.assists * 10 + self.shots * 0.5 + self.shp * 10
        self.first_centre_average = self.first_line_average + faceoff_score
        self.third_line_average = self.goals * 5 + self.assists * 5 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.shp * 10
        self.third_centre_average = self.third_line_average + faceoff_score
        self.fourth_line_average = self.goals * 2 + self.assists * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.shp * 10
        self.fourth_centre_average = self.fourth_line_average + faceoff_score
        self.first_pair_average = self.second_pair_average = self.third_pair_average = self.goalie_average = -1
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
        first_line_average: 4,
        first_centre_average: 2,
        third_line_average: 2,
        third_centre_average: 1,
        fourth_line_average: 2,
        fourth_centre_average: 1,
        first_pair_average: 2,
        second_pair_average: 2,
        third_pair_average: 2
      }
    end

    def replacement_level_init
    {
      first_line_average: 0,
      first_centre_average: 0,
      third_line_average: 0,
      third_centre_average: 0,
      fourth_line_average: 0,
      fourth_centre_average: 0,
      first_pair_average: 0,
      second_pair_average: 0,
      third_pair_average: 0,
      goalie_average: 0
    }
    end

    def overall_score
      Player.above_repl_array.map{|role| self.send(role)}.max
    end

    def calculate_ratings(redo_scores = false)
      self.calculate_role_points if redo_scores
      roles_array = []
      self.roles.map{|role| role[0]}.each do |role|
        the_role = Role.new({name: role, spots: self.role_positions[role.to_sym], replacement_level: self.replacement_level_init[role.to_sym]})
        roles_array.push(the_role)
      end
      Player.all.find_each do |player|
        roles_array.each do |role|
          raw_score = player.send(role.name)
          begin
            player.send(role.above_repl_key + "=", raw_score - role.replacement_level)
          rescue => e
            puts "Error calculating points above repl for #{role.name} for #{player.first_name} #{player.last_name}"
          end
        end
        player.save
      end
    end
    
  end
end

Player.calculate_ratings(true)
