# frozen_string_literal: true

class Calc::BestOf < Calc::Base
  def disciplines
    @disciplines ||= begin
      single_klas = Score
      group_klass = GroupScore.regular
      dis = []
      [
        [:hb, :female, single_klas, nil],
        [:hb, :male, single_klas, nil],
        [:hl, :female, single_klas, nil],
        [:hl, :male, single_klas, nil],
        [:gs, :female, group_klass, nil],
        [:la, :female, group_klass, nil],
        [:la, :male, group_klass, nil],
        [:hb, :female, single_klas, 2016],
      ].each do |discipline, gender, klass, year|
        scores = klass.best_of(discipline, gender, year).order(:time).first(100).map(&:decorate)
        next if scores.blank?

        dis.push(
          discipline:,
          gender:,
          scores:,
          year:,
        )
      end
      dis
    end
  end
end
