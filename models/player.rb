require "active_record"

class Player < ActiveRecord::Base

  enum pos: [:forward, :defence, :goalie, :rover]

  def first_line_average
    self.g * 10 + self.a * 10 + self.sog * 0.5
  end

  def third_line_average
    
  end

  def fourth_line_average

  end

  def first_pair_average

  end

  def second_pair_average

  end

  def third_pair_average

  end

  def goalie_average

  end
end