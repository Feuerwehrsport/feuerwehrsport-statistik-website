class CompetitionDecorator < AppDecorator
  decorates_association :place
  decorates_association :event
  decorates_association :score_type
  decorates_association :competition_files
  decorates_association :teams

  localizes :date

  def to_s
    full_name
  end

  def page_title
    "#{full_name} - Wettkampf"
  end

  def short_name
    "#{place.name} ´#{object.date.strftime('%y')}"
  end

  def date_with_place
    "#{object.date.strftime('%d.%m.')} - #{place.name} "
  end

  def short_date_with_place
    "#{object.date.strftime('%d.%m.')} #{place.name.truncate(15)} "
  end

  def full_name
    text = ''
    text += "#{object.date.strftime('%d.%m.%Y')} - " if date.present?
    text += "#{place.name}, " if place.present?
    text += event.name.to_s if event.present?
    text += " (#{name})" if name.present?
    text
  end

  def overview_name
    text = name.present? ? " (#{name.truncate(25)})" : ''
    "#{event.name} - #{place.name} - #{object.date.strftime('%d.%m.%Y')}#{text}"
  end

  def group_assessment(discipline, gender)
    object.group_assessment(discipline, gender).map(&:decorate)
  end
end
