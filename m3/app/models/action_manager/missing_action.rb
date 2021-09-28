# frozen_string_literal: true

class ActionManager::MissingAction < ActionManager::Action
  def link_to?
    false
  end
end
