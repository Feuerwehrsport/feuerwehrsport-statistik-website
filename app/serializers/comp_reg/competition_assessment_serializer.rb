module CompReg
  class CompetitionAssessmentSerializer < ActiveModel::Serializer
    attributes :discipline, :gender, :name, :id
  end
end
