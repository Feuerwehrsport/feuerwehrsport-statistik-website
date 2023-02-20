# frozen_string_literal: true

class Pdf2Table::OutputUploader < M3::ApplicationUploader
  def extension_white_list
    %w[csv ods]
  end

  def content_type_whitelist
    [
      'text/csv',
      'text/comma-separated-values',
      'application/vnd.oasis.opendocument.spreadsheet',
    ]
  end
end
