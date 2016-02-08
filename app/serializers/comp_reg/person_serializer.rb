module CompReg
  class PersonSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :statitics_person_id, :gender, :assessments

    def statitics_person_id
      object.person_id
    end

    def assessments
      object.competition_assessments.map(&:id)
    end
  end
end
