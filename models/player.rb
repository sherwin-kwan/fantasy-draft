require "active_record"

class Player < ActiveRecord::Base

  enum pos: {forward: 0, defence: 1, goalie: 2, rover: 3}
  enum role: {:first_line_average => 0,
    :third_line_average => 1,
    :fourth_line_average => 2,
    :first_pair_average => 3,
    :second_pair_average => 4,
    :third_pair_average => 5,
    :goalie_average => 6}

  scope :caphit_missing, -> {
    all.where('aav IS NULL')
  }
  scope :this_year, -> {
    all.where(year: 2024)
  }

  def capfriendly_case
    (self.first_name.downcase + " " + self.last_name.downcase).gsub(" ", "-")
  end

  class << self

    def above_repl_roles
      [:first_line_above_repl,
      :third_line_above_repl,
      :fourth_line_above_repl,
      :first_pair_above_repl, 
      :second_pair_above_repl,
      :third_pair_above_repl, 
      :goalie_above_repl]
    end
  end
end