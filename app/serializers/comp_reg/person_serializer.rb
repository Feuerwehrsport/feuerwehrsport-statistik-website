module CompReg
  class PersonSerializer < ActiveModel::Serializer
    attributes :id, :team_id, :team_name, :first_name, :last_name, :statitics_person_id, :gender, :assessment_participations, :tag_names

    def statitics_person_id
      object.person_id
    end

    def assessment_participations
      object.person_assessment_participations.map { |participation| participation.to_serializer }
    end
  end
end
