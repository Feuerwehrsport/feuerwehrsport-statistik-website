# frozen_string_literal: true

class ImageAsset < Asset
  default_scope { order(:name, :file).where(image: true) }
end
