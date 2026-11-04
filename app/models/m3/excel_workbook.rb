# frozen_string_literal: true

M3::ExcelWorkbook = Struct.new(:wb, :name, :structure) do
  def add_sheet(collection)
    wb.add_worksheet(name:) do |sheet|
      percent = sheet.styles.add_style(format_code: '0.0%;[Red]-0.0%')
      sheet.add_row(structure.map(&:label))
      row_index = 0
      collection.each do |res|
        row_index += 1
        column_index = -1
        row_values = structure.map do |field|
          column_index += 1
          value = field.value(res)
          if field.options[:clickable] && value.present?
            sheet.add_hyperlink(location: value, ref: Axlsx.cell_r(column_index, row_index))
          end
          value
        end
        sheet.add_row(row_values,
                      types: structure.map { |field| field.excel_type(res) },
                      style: structure.map { |field| field.excel_style(res, percent:) })
      end
      structure.edit_sheet(sheet)
    end
  end
end
