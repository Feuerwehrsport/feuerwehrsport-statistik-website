# frozen_string_literal: true

class LinkSerializer < ActiveModel::Serializer
  include URLSupport
  attributes :id, :label, :linkable_id, :linkable_type, :url, :linkable_url

  def linkable_url
    return if object.linkable.blank?

    url_for(object.linkable)
  rescue ActionController::UrlGenerationError
    root_path
  end
end
