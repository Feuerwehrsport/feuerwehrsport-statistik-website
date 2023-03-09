# frozen_string_literal: true

module PdfSupport
  def configure_prawn(options = {})
    title = options.delete(:title) || page_title
    filename = options.delete(:filename) || "#{title.parameterize}.pdf"
    info = {
      Title: title,
      Author: 'Feuerwehrsport-Statistik.de',
      Creator: 'Feuerwehrsport-Statistik.de',
      CreationDate: options.delete(:created_at) || Time.current,
    }
    prawn_options = {
      page_size: 'A4',
      margin: [36, 36, 40, 36],
      info: info,
    }

    prawnto(prawn: prawn_options.merge(options), filename: filename, inline: true)
  end
end
