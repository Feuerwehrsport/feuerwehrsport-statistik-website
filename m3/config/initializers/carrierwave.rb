# frozen_string_literal: true

module CarrierWave::MiniMagick
  def quality(percentage)
    manipulate! do |img|
      img.quality(percentage.to_s)
      img = yield(img) if block_given?
      img
    end
  end
end
