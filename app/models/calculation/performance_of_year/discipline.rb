module Calculation
  module PerformanceOfYear
    class Discipline < Struct.new(:discipline, :gender, :entries)
      include Draper::Decoratable

      def self.get(year, count=nil)
        [
          [year.to_i > 2016 ? :hw : :hb, :female],
          [:hb, :male],
          [:hl, :female],
          [:hl, :male],
          [:gs, :female],
          [:la, :female],
          [:la, :male],
        ].map! do |discipline, gender|
          klass = ::Discipline.group?(discipline) ? PerformanceOfYear::Team : PerformanceOfYear::Person
          discipline_entries = klass.entries(year, discipline, gender)
          discipline_entries = discipline_entries.first(count) if count.present?
          new(discipline, gender, discipline_entries)
        end
      end
    end
  end
end