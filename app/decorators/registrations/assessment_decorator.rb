# frozen_string_literal: true

class Registrations::AssessmentDecorator < AppDecorator
  decorates_association :band

  def to_s
    show_only_name? ? name : [name, discipline_name(discipline)].compact_blank.join(' - ')
  end

  def shortcut
    show_only_name? ? name : [name, discipline_name_short(discipline)].compact_blank.join(' - ')
  end

  def with_image
    h.safe_join([discipline_image(discipline), ' ', to_s])
  end
end
