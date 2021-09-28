# frozen_string_literal: true

class M3::AssetDecorator < ApplicationDecorator
  def to_s
    object.name.presence || object.file
  end

  def url
    object.file.url
  end

  def file_name
    attributes['file']
  end

  def image_preview
    h.image_tag(file.thumb.url, class: 'image-preview') if image?
  end
end
