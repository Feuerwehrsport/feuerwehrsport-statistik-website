# frozen_string_literal: true

module DefaultActions
  extend ActiveSupport::Concern

  included do
    helper_method :collection_redirect_url
    helper_method :member_redirect_url
    helper_method :decorator_class
    helper_method :resource_name
  end

  class_methods do
    def default_actions(*action_names, for_class: nil, resource_name: nil, collection_name: nil, singleton: false,
                        page_size: nil, decorator_class: nil, guard_destroy: false)
      action_names = %i[index new create show edit update destroy] if action_names.empty?

      define_method(:action_names)    { action_names }
      define_method(:resource_class)  { for_class }       if for_class
      define_method(:resource_name)   { resource_name }   if resource_name
      define_method(:collection_name) { collection_name } if collection_name
      define_method(:page_size)       { page_size }       if page_size
      define_method(:decorator_class) { decorator_class }
      define_method(:guard_destroy?)  { guard_destroy }

      before_action_once :preauthorize_action
      before_action_once :assign_parent_resource
      include DefaultActions::Shared
      include DefaultActions::Index   if action_names.include?(:index)
      include DefaultActions::New     if action_names.include?(:new)
      include DefaultActions::Create  if action_names.include?(:create)
      include DefaultActions::Show    if action_names.include?(:show)
      include DefaultActions::Edit    if action_names.include?(:edit)
      include DefaultActions::Update  if action_names.include?(:update)
      include DefaultActions::Destroy if action_names.include?(:destroy)
      include DefaultActions::Move    if action_names.include?(:move)
      before_action :authorize_action

      return unless singleton

      define_method(:collection_redirect_url) do
        if member_action(:show).redirect_to?
          { action: :show }
        else
          root_path
        end
      end
    end
  end

  def member_redirect_url
    if member_action(:show).redirect_to?
      { action: :show, id: form_resource.to_param }
    else
      collection_redirect_url
    end
  end

  def collection_redirect_url
    if collection_action(:index).redirect_to?
      { action: :index }
    else
      root_path
    end
  end

  def action_names
    []
  end
end
