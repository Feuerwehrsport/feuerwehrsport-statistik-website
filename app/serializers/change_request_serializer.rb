# frozen_string_literal: true

class ChangeRequestSerializer < ActiveModel::Serializer
  attributes :id, :content, :done_at, :created_at, :files, :user

  def files
    object.files.map do |file|
      file.to_h.slice(:filename, :content_type)
    end
  end

  def user
    object.user.try(:to_serializer).try(:as_json)
  end

  def created_at
    object.object.created_at.as_json
  end
end
