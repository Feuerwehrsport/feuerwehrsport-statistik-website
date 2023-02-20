# frozen_string_literal: true

class Registrations::AssessmentDecorator < AppDecorator
  def to_s
    show_only_name? ? name : [name, discipline_name(discipline)].reject(&:blank?).join(' - ')
  end

  def shortcut
    show_only_name? ? name : [name, discipline_name_short(discipline)].reject(&:blank?).join(' - ')
  end

  def with_gender
    show_only_name? ? name : "#{self} #{g(gender)}"
  end

  def with_image
    h.safe_join([discipline_image(discipline), ' ', to_s])
  end
end
