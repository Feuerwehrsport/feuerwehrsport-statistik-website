# frozen_string_literal: true

class ActionManager::BackendBLABadgesGenerateActionDecorator < ActionManager::MemberActionDecorator
  def url
    h.new_backend_bla_badge_generator_path
  end

  def link_to?
    h.can?(:create, BLA::BadgeGenerator)
  end
end
