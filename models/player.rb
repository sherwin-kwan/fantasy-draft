require "active_record"

class Player < ActiveRecord::Base

  enum pos: [:forward, :defence, :goalie, :rover]
  enum role: [:first_line_average,
    :third_line_average,
    :fourth_line_average,
    :first_pair_average, 
    :second_pair_average,
    :third_pair_average, 
    :goalie_average]

  scope :caphit_missing, -> {
    all.where('aav IS NULL')
  }
  scope :this_year, -> {
    all.where(year: 2023)
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