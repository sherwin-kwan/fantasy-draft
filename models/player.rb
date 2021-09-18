require "active_record"

class Player < ActiveRecord::Base

  enum pos: [:forward, :defence, :goalie, :rover]

  scope :caphit_missing, -> {
    all.where('aav IS NULL')
  }

  def first_line_average
    self.g * 10 + self.a * 10 + self.shots * 0.5 + self.shp * 10
  end

  def third_line_average
    self.g * 5 + self.a * 5 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.shp * 10
  end

  def fourth_line_average
    self.g * 2 + self.a * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.shp * 10
  end

  def first_pair_average
    self.g * 10 + self.a * 10 + self.shots * 0.5 + self.hits * 0.5 + self.blocks * 1 + self.tk * 1 - self.gv * 1 + self.plus_minus * 2 + self.shp * 10
  end

  def second_pair_average
    self.g * 6 + self.a * 6 + self.hits * 1.5 + self.blocks * 2 + self.tk * 2 - self.gv * 2 + self.plus_minus * 2 + self.shp * 10
  end

  def third_pair_average
    self.g * 2 + self.a * 2 + self.hits * 2 + self.blocks * 2.5 + self.tk * 2.5 - self.gv * 2.5 + self.plus_minus * 2 + self.shp * 10
  end

  def goalie_average
    self.sv - self.ga * 7 + self.wins * 5 + self.shutouts * 10
  end

  def capfriendly_case
    (self.first_name.downcase + " " + self.last_name.downcase).gsub(" ", "-")
  end
end