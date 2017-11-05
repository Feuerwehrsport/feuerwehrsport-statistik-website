module DisciplineNamesAndImages
  def discipline_name(discipline)
    t("discipline.#{discipline}")
  end

  def discipline_image_name_short(discipline, gender = nil)
    text = "#{discipline_image(discipline)} #{discipline_name_short(discipline)}"
    text += " #{g_symbol(gender)}" if gender.present?
    text.html_safe
  end

  def discipline_name_short(discipline)
    discipline = :hb if discipline.to_sym == :hw
    discipline = :zk if discipline.to_sym == :zw
    discipline.to_s.upcase
  end

  def discipline_image(discipline, options = {})
    discipline = :hb if discipline.to_sym == :hw
    discipline = :zk if discipline.to_sym == :zw
    options = { width: 20, title: discipline_name(discipline) }.merge(options)
    h.image_tag("disciplines/#{discipline}.png", options)
  end

  def discipline_color(discipline)
    t("discipline.#{discipline}_color")
  end

  def group_discipline?(discipline)
    discipline.to_sym.in? %i[gs fs la]
  end
end
