# frozen_string_literal: true

class ActionManager::CollectionActionDecorator < ActionManager::ActionDecorator
  def url
    { action: name }
  end
end
