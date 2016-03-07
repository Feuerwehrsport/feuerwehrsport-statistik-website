module CompReg
  class TeamSerializer < ActiveModel::Serializer
    attributes :id, :name, :shortcut, :team_number, :statitics_team_id, :gender, :assessments, :tag_names

    def statitics_team_id
      object.team_id
    end

    def assessments
      object.competition_assessments.map(&:id)
    end
  end
end
