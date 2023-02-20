# frozen_string_literal: true

class PersonParticipationDecorator < AppDecorator
  decorates_association :person
  decorates_association :group_score

  def to_s
    "#{person} - #{group_score}"
  end

  delegate :competition, to: :group_score
end
