# frozen_string_literal: true

module DisciplineNamesAndImages
  def discipline_name(discipline)
    t("discipline.#{discipline}")
  end

  def discipline_image_name_short(discipline, gender = nil)
    output = [discipline_image(discipline), discipline_name_short(discipline)]
    output.push(g_symbol(gender)) if gender.present?
    h.safe_join(output, ' ')
  end

  def discipline_name_short(discipline)
    discipline.to_s.upcase
  end

  def discipline_image(discipline, options = {})
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
