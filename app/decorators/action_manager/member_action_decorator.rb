# frozen_string_literal: true

class ActionManager::MemberActionDecorator < ActionManager::ActionDecorator
  def resource
    @resource ||= ApplicationDecorator.try_to_decorate(object.resource)
  end

  def url
    { action: name, id: resource.to_param }
  end
end
