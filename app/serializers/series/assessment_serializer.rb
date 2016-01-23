module Series
  class AssessmentSerializer < ActiveModel::Serializer
    attributes :id, :translated_gender, :name, :discipline, :round_id

    def name
      object.to_s
    end
  end
end
