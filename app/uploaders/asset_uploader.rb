# frozen_string_literal: true

class AssetUploader < ApplicationUploader
  version :thumb, if: :image? do
    process resize_to_fit: [100, 100]
  end

  def image?(new_file = file)
    new_file.try(:content_type).present? && new_file.content_type.start_with?('image')
  end

  def store_dir
    # path from former m3 engine, existing files are stored there
    "uploads/m3/assets/#{mounted_as}/#{model.id}"
  end
end
