class Registrations::AssessmentDecorator < AppDecorator
  def to_s
    [name, discipline_name(discipline)].reject(&:blank?).join(' - ')
  end

  def shortcut
    [name, discipline_name_short(discipline)].reject(&:blank?).join(' - ')
  end

  def with_gender
    "#{self} #{g(gender)}"
  end

  def with_image
    h.safe_join([discipline_image(discipline), ' ', to_s])
  end
end
