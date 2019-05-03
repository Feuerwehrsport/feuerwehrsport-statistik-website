class Series::RoundDecorator < AppDecorator
  decorates_association :cups
  localizes_boolean :official

  def to_s
    "#{name} #{year}"
  end

  def page_title
    "#{self} - Wettkampfserie"
  end

  def cup_count_with_status
    if cups_left.zero?
      cup_count
    else
      "#{cup_count} von #{full_cup_count}"
    end
  end
end
