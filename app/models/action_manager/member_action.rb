# frozen_string_literal: true

class ActionManager::MemberAction < ActionManager::Action
  def link_to?
    super && resource.persisted?
  end

  def resource
    resource_or_class
  end
end
