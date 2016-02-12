module Helper::PrawnHelper
  def pdf_footer(pdf, name=nil)
    full_name = [name, "Feuerwehrsport-Statistik.de"].reject(&:blank?).join(" - ")
    pdf.page_count.times do |i|
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom], width: pdf.bounds.width, height: 30) do
        pdf.go_to_page i+1
        pdf.move_down 3

        pdf.text "#{full_name} - Seite #{i+1} von #{pdf.page_count}", align: :center
      end
    end
  end
end