# frozen_string_literal: true

# Excel export of an index structure (see IndexStructures#export_index)
Ui::ExcelWorkbook = Struct.new(:name, :structure, :collection, :basename) do
  include XlsxSupport

  def filename
    "#{basename}.xlsx"
  end

  def build(workbook)
    workbook.add_worksheet(name: name&.truncate(31)) do |sheet|
      percent = sheet.styles.add_style(format_code: '0.0%;[Red]-0.0%')
      sheet.add_row(structure.map(&:label))
      collection.each_with_index do |res, index|
        add_resource_row(sheet, res, index + 1, percent)
      end
      structure.edit_sheet(sheet)
    end
  end

  private

  def add_resource_row(sheet, res, row_index, percent)
    row_values = structure.each_with_index.map do |field, column_index|
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
end
