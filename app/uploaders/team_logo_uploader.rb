# frozen_string_literal: true

class TeamLogoUploader < M3::ApplicationUploader
  def store_dir
    "uploads/teams/#{model.id}"
  end

  process resize_to_limit: [1000, 1000]
  process_optimize_images

  version :tile do
    process resize_and_pad: [100, 100]
    process_optimize_images
  end

  version :thumb do
    process resize_and_pad: [24, 24]
    process_optimize_images
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end
end
