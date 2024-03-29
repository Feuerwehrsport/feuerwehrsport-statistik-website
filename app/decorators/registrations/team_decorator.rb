# frozen_string_literal: true

class Registrations::TeamDecorator < AppDecorator
  decorates_association :competition
  decorates_association :band
  decorates_association :team_assessment_participations
  decorates_association :admin_user
  decorates_association :federal_state
  localizes_gender

  def to_s
    name
  end

  def with_number
    "#{name} #{team_number}"
  end

  def hint_to_hint
    h.simple_format(competition.hint_to_hint)
  end

  def band_with_tags
    ([band] + tag_names).join(', ')
  end
end
