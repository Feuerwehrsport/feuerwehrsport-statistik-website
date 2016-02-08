module CompReg
  class CompetitionSerializer < ActiveModel::Serializer
    attributes :name, :place, :date, :description, :teams, :assessments

    def teams
      object.teams.map { |team| team.to_serializer }
    end

    def assessments
      object.competition_assessments.map { |assessment| assessment.to_serializer }
    end
  end
end
