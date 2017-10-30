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
end
