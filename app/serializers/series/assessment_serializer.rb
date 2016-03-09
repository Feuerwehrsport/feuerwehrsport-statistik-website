module Series
  class AssessmentSerializer < ActiveModel::Serializer
    attributes :id, :translated_gender, :name, :discipline, :round_id, :type, :gender, :real_name

    def name
      object.to_s
    end

    def real_name
      object.name
    end
  end
end
