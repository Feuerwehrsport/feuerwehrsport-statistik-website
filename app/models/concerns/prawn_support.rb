module PrawnSupport
  extend ActiveSupport::Concern

  class_methods do
    def build(*args)
      instance = new(*args)
      instance.unicode { instance.build }
      instance
    end

    def decorates_assigned(*methods)
      methods.each do |method|
        define_method(method) do
          to_h[method].decorate
        end
      end
    end
  end

  def bytestream
    @bytestream ||= prawn.render
  end

  def filename
    "#{send(members.first).decorate.to_s.parameterize}.pdf"
  end

  def unicode(&block)
    font_path = Rails.root.join('app/assets/fonts')
    prawn.font_families.update(
      'DejaVuSans' => {
        normal: "#{font_path}/DejaVuSans.ttf",
        bold: "#{font_path}/DejaVuSans-Bold.ttf",
        italic: "#{font_path}/DejaVuSans-Oblique.ttf",
        bold_italic: "#{font_path}/DejaVuSans-BoldOblique.ttf",
      },
      'Arial' => {
        normal: "#{font_path}/Arial.ttf",
        bold: "#{font_path}/Arial_Bold.ttf",
        italic: "#{font_path}/Arial_Italic.ttf",
        bold_italic: "#{font_path}/Arial_Bold_Italic.ttf",
      },
      'Helvetica' => {
        normal: "#{font_path}/Helvetica-Normal.ttf",
      },
    )

    prawn.fallback_fonts(%w[Helvetica Arial])
    prawn.font('DejaVuSans', &block)
  end

  protected

  def prawn
    @prawn ||= Prawn::Document.new(default_prawn_options)
  end

  def default_prawn_options
    {
      margin: [0, 0, 0, 0],
      page_size: 'A4',
    }
  end

  def header(title, subtitle = nil, discipline: nil)
    prawn.bounding_box [prawn.bounds.left, prawn.bounds.top], width: prawn.bounds.width, height: 40 do
      position = prawn.cursor
      prawn.text(title, align: :center, size: 15)
      prawn.text(subtitle, align: :center, size: 12) if subtitle.present?
      if discipline.present?
        prawn.image(Rails.root.join("app/assets/images/disciplines/#{discipline}.png"),
                    width: 30, at: [10, position])
      end
    end
  end

  def footer(title = nil, subtitle = nil)
    full_name = [title, subtitle, 'Feuerwehrsport-Statistik.de'].reject(&:blank?).join(' - ')
    prawn.page_count.times do |i|
      prawn.bounding_box([prawn.bounds.left, prawn.bounds.bottom], width: prawn.bounds.width, height: 30) do
        prawn.go_to_page i + 1
        prawn.move_down 3
        prawn.text("#{full_name} - Seite #{i + 1} von #{prawn.page_count}", align: :center, size: 10)
      end
    end
  end

  def t(*args)
    I18n.t(*args)
  end
end
