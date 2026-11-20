# frozen_string_literal: true

# Excel exports as models: including class implements +build(workbook)+ and +filename+
module XlsxSupport
  def bytestream
    @bytestream ||= begin
      package = Axlsx::Package.new
      build(package.workbook)
      package.to_stream.read
    end
  end

  def t(*)
    I18n.t(*)
  end
end
