# frozen_string_literal: true

class ActionManager::EditActionDecorator < ActionManager::MemberActionDecorator
  def link_to?
    super && (h.action_name != 'update')
  end
end
