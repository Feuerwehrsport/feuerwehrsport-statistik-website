# frozen_string_literal: true

module GenderNames
  def g(gender)
    t("gender.#{normalize_gender(gender)}")
  end

  def g_symbol(gender)
    t("gender.#{normalize_gender(gender)}_symbol")
  end

  def normalize_gender(gender)
    gender = gender == 1 ? :male : :female if gender.in? [0, 1]
    gender = gender.to_sym if gender.is_a?(String)
    gender
  end

  GENDER_COLORS = {
    female: '#EA580C',
    male: '#1D4ED8',
  }.freeze
  def gender_color(gender)
    GENDER_COLORS[normalize_gender(gender)]
  end
end
