# frozen_string_literal: true

class ActionManager::DestroyActionDecorator < ActionManager::MemberActionDecorator
  def link_to(options = {})
    super(options.reverse_merge(method: :delete, data: { confirm: h.t3('actions.confirm_destroy') }))
  end

  def link_to?
    super && guard_destroy_link_to?
  end

  protected

  def guard_destroy_link_to?
    return true unless controller.guard_destroy?

    resource_class = object.resource.class
    associations = resource_class.reflect_on_all_associations.select do |association|
      association.options[:dependent].to_s.starts_with?('restrict_with_')
    end
    associations.all? do |association|
      object.resource.public_send(association.name).blank?
    end
  end
end
