# frozen_string_literal: true

module PeopleHelper
  def series_row
    @series_structs.each do |name, years|
      name_s = { rowspan: years.values.flatten.count, name: }
      years.each do |year, structs|
        year_s = { rowspan: structs.count, year: }
        structs.each_with_index do |struct, _i|
          yield name_s, year_s, struct.assessment, struct.row, struct.cups
          name_s = nil if name_s.present?
          year_s = nil if year_s.present?
        end
      end
    end
  end
end
