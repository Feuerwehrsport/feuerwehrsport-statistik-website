module PeopleHelper
  def series_row
    @series_structs.each do |name, years|
      name_s = OpenStruct.new(rowspan: years.values.flatten.count, name: name)
      years.each do |year, structs|
        year_s = OpenStruct.new(rowspan: structs.count, year: year)
        structs.each_with_index do |struct, i|
          yield name_s, year_s, struct.assessment, struct.row, struct.cups
          name_s = nil if name_s.present?
          year_s = nil if year_s.present?
        end
      end
    end
  end
end