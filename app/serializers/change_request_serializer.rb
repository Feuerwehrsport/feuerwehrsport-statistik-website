class ChangeRequestSerializer < ActiveModel::Serializer
  attributes :id, :content, :done_at, :created_at
end
