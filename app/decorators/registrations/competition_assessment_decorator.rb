class Registrations::CompetitionAssessmentDecorator < AppDecorator
  def to_s
    [name, discipline_name(discipline)].reject(&:blank?).join(' - ')
  end

  def shortcut
    [name, discipline_name_short(discipline)].reject(&:blank?).join(' - ')
  end

  def with_gender
    "#{self} #{g(gender)}"
  end
end
