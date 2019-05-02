class CompetitionDecorator < AppDecorator
  decorates_association :place
  decorates_association :event
  decorates_association :score_type
  decorates_association :competition_files
  decorates_association :teams

  localizes :date
  localizes_boolean :scores_for_bla_badge

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

  def linked_name
    title = []
    title.push(event.name) if object.event.present?
    title.push(place.name) if object.place.present?
    title.push(name) if name.present?
    title = title.join(' - ')
    h.link_to(title.truncate(60), h.competition_path(self), title: title)
  end

  %i[hb_female hb_male hl_female hb_male gs fs_female fs_male la_female la_male].each do |method|
    define_method method do
      h.count_or_zero(object.public_send(method))
    end
  end
end
