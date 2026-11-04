# frozen_string_literal: true

class ActionManager::CollectionAction < ActionManager::Action
  def resource_class
    resource_or_class
  end
end
