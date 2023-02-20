# frozen_string_literal: true
class GroupScoreCategorySerializer < ActiveModel::Serializer
  attributes :id, :group_score_type, :competition, :name

  def group_score_type
    object.group_score_type.to_s
  end

  def competition
    object.competition.to_s
  end
end
