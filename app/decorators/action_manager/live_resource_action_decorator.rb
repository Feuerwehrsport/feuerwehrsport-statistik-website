class ActionManager::LiveResourceActionDecorator < ActionManager::ActionDecorator
  def url
    h.url_for(controller: "/#{h.resource_name.pluralize}", action: (h.action_name == 'index' ? :index : :show), id: h.params[:id])
  rescue
    nil
  end

  def link_to?
    url.present?
  end
end
