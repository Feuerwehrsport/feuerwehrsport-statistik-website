class Series::RoundDecorator < ApplicationDecorator
  decorates_association :cups

  def to_s
    "#{name} #{year}"
  end

  def cup_count_with_status
    if cups_left == 0
      cup_count
    else
      "#{cup_count} von #{full_cup_count}"
    end
  end
end