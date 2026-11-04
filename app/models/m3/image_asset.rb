# frozen_string_literal: true

class M3::ImageAsset < M3::Asset
  default_scope { order(:name, :file).where(image: true) }
end
