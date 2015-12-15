class TeamLogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :file

  def store_dir
    "uploads/teams/#{model.id}"
  end

  process resize_to_limit: [1000, 1000]

  version :tile do
    process resize_and_pad: [100, 100]
  end

  version :thumb do
    process resize_and_pad: [24, 24]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
