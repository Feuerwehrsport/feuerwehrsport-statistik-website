# frozen_string_literal: true

class Series::PersonParticipation < Series::Participation
  belongs_to :person

  def entity
    person
  end

  def entity_id
    person_id
  end
end
