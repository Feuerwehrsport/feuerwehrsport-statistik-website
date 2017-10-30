module Helper::PrawnHelper
  def pdf_header(pdf, title, subtitle = nil, discipline: nil)
    pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], width: pdf.bounds.width, height: 40 do
      position = pdf.cursor
      pdf.text(title, align: :center, size: 15)
      pdf.text(subtitle, align: :center, size: 12) if subtitle.present?
      if discipline.present?
        pdf.image "#{Rails.root}/app/assets/images/disciplines/#{discipline}.png", width: 30, at: [10, position]
      end
    end
  end

  def pdf_footer(pdf, title = nil, subtitle = nil)
    full_name = [title, subtitle, 'Feuerwehrsport-Statistik.de'].reject(&:blank?).join(' - ')
    pdf.page_count.times do |i|
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom], width: pdf.bounds.width, height: 30) do
        pdf.go_to_page i + 1
        pdf.move_down 3
        pdf.text("#{full_name} - Seite #{i + 1} von #{pdf.page_count}", align: :center, size: 10)
      end
    end
  end
end
