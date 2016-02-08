module CompReg
  class TeamSerializer < ActiveModel::Serializer
    attributes :name, :shortcut, :statitics_team_id, :gender, :people, :assessments

    def statitics_team_id
      object.team_id
    end

    def assessments
      object.competition_assessments.map(&:id)
    end

    def people
      object.people.map { |person| person.to_serializer }
    end
  end
end
