# frozen_string_literal: true

module GenderNames
  def g(gender)
    t("gender.#{normalize_gender(gender)}")
  end

  def g_symbol(gender)
    t("gender.#{normalize_gender(gender)}_symbol")
  end

  def g_color(gender)
    t("gender.#{normalize_gender(gender)}_color")
  end

  def normalize_gender(gender)
    gender = gender == 1 ? :male : :female if gender.in? [0, 1]
    gender
  end

  GENDER_COLORS = {
    female: '#FEAE97',
    male: '#97E6FE',
  }.freeze
  def gender_color(gender)
    GENDER_COLORS[normalize_gender(gender)]
  end
end
