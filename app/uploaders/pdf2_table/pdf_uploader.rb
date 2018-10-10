class Pdf2Table::PdfUploader < M3::ApplicationUploader
  def extension_white_list
    %w[pdf]
  end

  def content_type_whitelist
    [
      'application/pdf',
    ]
  end
end
