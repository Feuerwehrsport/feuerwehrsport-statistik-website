# frozen_string_literal: true

class M3::ImageAssetsController < M3::AssetsController
  default_index do |t|
    t.col :image_preview
    t.col :name
    t.col :file_name, sortable: :file
    t.col :created_at
  end
end
