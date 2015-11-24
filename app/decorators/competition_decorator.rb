class CompetitionDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :place, :event, :date, :name

  decorates_association :place
  decorates_association :event
  decorates_association :score_type

  def to_s
    full_name
  end

  def short_name
    "#{place.name} ´#{date.strftime('%y')}"
  end

  def date_with_place
    "#{date.strftime('%d.%m.')} - #{place.name} "
  end

  def full_name
    text = "#{date.strftime('%d.%m.%Y')} - #{place.name}, #{event.name}"
    text += " (#{name})" if name.present?
    text
  end

  def overview_name
    text = name.present? ? " (#{name.truncate(25)})" : "" 
    "#{event.name} - #{place.name} - #{date.strftime('%d.%m.%Y')}#{text}"
  end

  def group_assessment(discipline, gender)
    object.group_assessment(discipline, gender).map(&:decorate)
  end
end
