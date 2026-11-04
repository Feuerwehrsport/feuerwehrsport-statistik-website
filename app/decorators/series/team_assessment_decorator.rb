# frozen_string_literal: true

class Series::TeamAssessmentDecorator < AppDecorator
  decorates_association :cups
  decorates_association :round

  def to_s
    [discipline_name(discipline), name].compact_blank.join(' - ')
  end

  def page_title
    "#{round} #{self} - Wettkampfserie"
  end

  def rows
    object.rows.map(&:decorate)
  end
end
