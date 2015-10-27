module ApplicationHelper
  COMPETITOR_POSITION = {
    la: [
      'Maschinist',
      'A-Länge',
      'Saugkorb',
      'B-Schlauch',
      'Strahlrohr links',
      'Verteiler',
      'Strahlrohr rechts'
    ],
    gs: [
      'B-Schlauch',
      'Verteiler',
      'C-Schlauch',
      'Knoten',
      'D-Schlauch',
      'Läufer'
    ],
    fs: [
      { female: 'Leiterwand', male: 'Haus '},
      { female: 'Hürde', male: 'Wand' },
      'Balken',
      'Feuer'
    ]
  }


  def count_table rows, options={}, &block
    ct = UI::CountTable.new rows, options, &block
    render 'ui/count_table', ct: ct
  end

  def table_of_contents &block
    toc = UI::TableOfContents.new
    toc.handle(capture_haml toc, &block).html_safe
  end

  def g(gender)
    t("gender.#{normalize_gender(gender)}")
  end

  def g_color(gender)
    t("gender.#{normalize_gender(gender)}_color")
  end

  def discipline_name(discipline)
    t("discipline.#{discipline}")
  end

  def discipline_image(discipline)
    image_tag(asset_path("disciplines/#{discipline}.png"), width: 20)
  end

  def discipline_color(discipline)
    t("discipline.#{discipline}_color")
  end

  def group_discipline?(discipline)
    discipline.to_sym.in? [:gs, :fs, :la]
  end

  def competitor_position(discipline, position, gender)
    name = COMPETITOR_POSITION[discipline.to_sym][position - 1]
    name = name[gender.to_sym] if name.is_a? Hash
    name
  end

  def normalize_gender(gender)
    gender = gender == 1 ? :male : :female if gender.in? [0, 1]
    gender
  end

  def count_or_zero(count)
    count > 0 ? count : ""
  end
end
