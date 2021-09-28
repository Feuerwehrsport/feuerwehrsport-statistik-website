# frozen_string_literal: true

module ActionManager
  extend ActiveSupport::Concern

  included do
    helper_method :collection_action
    helper_method :collection_actions
    helper_method :member_action
    helper_method :member_actions
    helper_method :m3_hero_max_actions

    collection_actions :index, :new, check_existence: true
    member_actions :show, :edit, :destroy, check_existence: true
  end

  class_methods do
    def collection_actions(*args, check_existence: false)
      define_method(:collection_actions) do
        actions = []
        args.each do |action_name|
          actn = add_collection_action(action_name, check_existence: check_existence)
          actions << actn if actn.link_to?
        end
        actions
      end
    end

    def member_actions(*args, check_existence: false)
      define_method(:member_actions) do |res = nil|
        actions = []
        res = res.object if res.respond_to?(:decorated?) && res.decorated?
        args.each do |action_name|
          actn = add_member_action(action_name, check_existence: check_existence, resource: res)
          actions << actn if actn.link_to?
        end
        actions
      end
    end
  end

  def collection_action(name)
    caction = collection_actions.detect { |action| action.name == name.to_sym }
    caction || MissingAction.new(name.to_sym, resource_class, current_ability, self).decorate
  end

  def add_collection_action(name, check_existence: true)
    add_action(name, CollectionAction, resource_class, check_existence: check_existence)
  end

  def member_action(name, resource: nil)
    maction = member_actions.detect { |action| action.name == name.to_sym }
    maction || MissingAction.new(name.to_sym, resource, current_ability, self).decorate
  end

  def add_member_action(name, check_existence: true, resource: nil)
    resource ||= form_resource || self.resource
    add_action(name, MemberAction, resource, check_existence: check_existence)
  end

  def m3_hero_max_actions
    3
  end

  private

  def add_action(name, action_class, resource_or_class, check_existence: true)
    name = name.to_sym if name.is_a?(String)
    existing = !check_existence || action_names.include?(name)
    action_class = existing ? action_class : MissingAction
    action_class.new(name, resource_or_class, current_ability, self).decorate
  end
end
