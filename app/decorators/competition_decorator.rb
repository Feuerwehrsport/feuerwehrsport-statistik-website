class CompetitionDecorator < ApplicationDecorator
  decorates_association :place
  decorates_association :event
  decorates_association :score_type

  def to_s
    full_name
  end

  def short_name
    "#{place.name} ´#{date.strftime('%y')}"
  end

  def full_name
    text = "#{date.strftime('%d.%m.%Y')} - #{place.name}, #{event.name}"
    text += " (#{name})" if name.present?
    text
  end
end
