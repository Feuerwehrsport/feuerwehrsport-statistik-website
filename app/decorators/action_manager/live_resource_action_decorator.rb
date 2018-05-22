class ActionManager::LiveResourceActionDecorator < ActionManager::ActionDecorator
  def url
    if resource_or_class.class == Class
      resource_name = resource_or_class.name.demodulize.underscore.pluralize
      h.url_for(controller: "/#{resource_name}", action: :index)
    else
      resource_name = resource_or_class.class.name.demodulize.underscore.pluralize
      h.url_for(controller: "/#{resource_name}", action: :show, id: resource_or_class.to_param)
    end
  rescue StandardError
    nil
  end

  def link_to?
    url.present?
  end
end
