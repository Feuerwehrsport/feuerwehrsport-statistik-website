class Series::AssessmentDecorator < AppDecorator
  decorates_association :cups
  decorates_association :participations
  decorates_association :round
  localizes_gender

  def to_s
    [discipline_name(discipline), name, gender_translated].select(&:present?).join(' - ')
  end

  def page_title
    "#{round} #{self} - Wettkampfserie"
  end

  def rows
    object.rows.map(&:decorate)
  end
end
