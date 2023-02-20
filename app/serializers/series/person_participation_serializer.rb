# frozen_string_literal: true

class Series::PersonParticipationSerializer < Series::ParticipationSerializer
  attributes :person_id, :participation_type

  def participation_type
    :person
  end
end
