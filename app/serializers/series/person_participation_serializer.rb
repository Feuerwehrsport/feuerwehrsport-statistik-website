module Series
  class PersonParticipationSerializer < ParticipationSerializer
    attributes :person_id, :participation_type

    def participation_type
      :person
    end
  end
end
