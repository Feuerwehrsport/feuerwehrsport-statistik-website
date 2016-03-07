module CompReg
  class CompetitionSerializer < ActiveModel::Serializer
    attributes :name, :place, :date, :description, :teams, :assessments, :people, :person_tag_list, :team_tag_list

    def teams
      object.teams.map { |team| team.to_serializer }
    end

    def people
      object.people.map { |person| person.to_serializer }
    end

    def assessments
      object.competition_assessments.map { |assessment| assessment.to_serializer }
    end
  end
end
