class ChangeRequestSerializer < ActiveModel::Serializer
  attributes :id, :content, :done_at, :created_at, :files

  def files
    object.files.map do |file|
      file.to_h.slice(:filename, :content_type)
    end
  end
end
