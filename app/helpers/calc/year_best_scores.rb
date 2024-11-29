# frozen_string_literal: true

class Calc::YearBestScores < Calc::Base
  attr_accessor :year

  def disciplines
    @disciplines ||= begin
      single_klas = Score
      group_klass = GroupScore.regular
      dis = []
      [
        [:hb, :female, single_klas],
        [:hb, :male, single_klas],
        [:hl, :female, single_klas],
        [:hl, :male, single_klas],
        [:gs, :female, group_klass],
        [:la, :female, group_klass],
        [:la, :male, group_klass],
      ].each do |discipline, gender, klass|
        scores = klass.best_of_year(year.to_i, discipline, gender).reorder(:time).decorate.to_a
        next if scores.blank?

        dis.push(
          discipline:,
          gender:,
          scores:,
        )
      end
      dis
    end
  end
end
