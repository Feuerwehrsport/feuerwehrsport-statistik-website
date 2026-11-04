# frozen_string_literal: true

class ImageAssetsController < AssetsController
  default_index do |t|
    t.col :image_preview, sortable: false
    t.col :name
    t.col :file_name, sortable: :file
    t.col :created_at
  end
end
