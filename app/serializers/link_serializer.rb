class LinkSerializer < ActiveModel::Serializer
  attributes :id, :label, :linkable_id, :linkable_type, :url, :linkable_url

  def linkable_url
    url_for(object.linkable) rescue root_path
  end

  def default_url_options
    Rails.configuration.action_controller.default_url_options
  end
end