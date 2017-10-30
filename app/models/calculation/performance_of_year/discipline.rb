module Calculation
  module PerformanceOfYear
    class Discipline < Struct.new(:discipline, :gender, :entries)
      include Draper::Decoratable

      def self.get(year, count = nil)
        [
          [year.to_i > 2016 ? :hw : :hb, :female],
          %i[hb male],
          %i[hl female],
          %i[hl male],
          %i[gs female],
          %i[la female],
          %i[la male],
        ].map do |discipline, gender|
          klass = ::Discipline.group?(discipline) ? PerformanceOfYear::Team : PerformanceOfYear::Person
          discipline_entries = klass.entries(year, discipline, gender)
          discipline_entries = discipline_entries.first(count) if count.present?
          new(discipline, gender, discipline_entries)
        end.select { |discipline| discipline.entries.present? }
      end
    end
  end
end
