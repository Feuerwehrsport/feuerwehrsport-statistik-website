Calculation::PerformanceOfYear::Discipline = Struct.new(:discipline, :gender, :entries) do
  include Draper::Decoratable

  def self.get(year, count = nil)
    all = [
      [year.to_i > 2016 ? :hw : :hb, :female],
      %i[hb male],
      %i[hl female],
      %i[hl male],
      %i[gs female],
      %i[la female],
      %i[la male],
    ].map do |discipline, gender|
      klass = if ::Discipline.group?(discipline)
                Calculation::PerformanceOfYear::Team
              else
                Calculation::PerformanceOfYear::Person
              end
      discipline_entries = klass.entries(year, discipline, gender)
      discipline_entries = discipline_entries.first(count) if count.present?
      new(discipline, gender, discipline_entries)
    end
    all.select { |discipline| discipline.entries.present? }
  end
end
