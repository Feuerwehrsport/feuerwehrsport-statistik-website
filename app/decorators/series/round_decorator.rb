class Series::RoundDecorator < ApplicationDecorator
  decorates_association :cups

  def to_s
    "#{name} #{year}"
  end
end