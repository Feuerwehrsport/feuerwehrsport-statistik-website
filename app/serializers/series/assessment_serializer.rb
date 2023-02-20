# frozen_string_literal: true

class Series::AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :gender, :name, :discipline, :round_id, :type, :gender_translated, :real_name

  def name
    object.to_s
  end

  def real_name
    object.name
  end
end
