# frozen_string_literal: true

class ActionManager::BackendBlaBadgesGenerateActionDecorator < ActionManager::MemberActionDecorator
  def url
    h.new_backend_bla_badge_generator_path
  end

  def link_to?
    h.can?(:create, Bla::BadgeGenerator)
  end
end
