# frozen_string_literal: true

class Api::BaseController < ApplicationController
  include Api::LoginActions
  include SerializerSupport

  skip_before_action :verify_authenticity_token
  rescue_from CanCan::AccessDenied do |exception|
    failed(message: exception.message)
  end

  def self.api_actions(*action_names)
    options              = action_names.extract_options!
    change_log           = options.delete(:change_log)
    clean_cache_disabled = options.delete(:clean_cache_disabled)
    for_class            = options.delete(:for_class) || controller_path.classify.gsub(/^Api::/, '').constantize
    default_form         = options.delete(:default_form)

    options[:for_class] = for_class
    default_actions(*action_names, **options)
    include Api::Actions::Index            if action_names.include?(:index)
    include Api::Actions::Create           if action_names.include?(:create)
    include ChangeLogSupport if change_log
    include CleanCacheSupport unless clean_cache_disabled

    default_form { |f| default_form.each { |field| f.permit field } } if default_form.present?

    define_method(:paginate?) { false }
  end

  protected

  def success(hash = {})
    respond_with(hash)
  end

  def failed(hash = {})
    respond_with({ message: failed_message }.merge(hash).merge(success: false))
  end

  def respond_with(hash = {})
    render json: handle_serializer(respond_defaults.merge(hash))
  end

  def collection_modulized_name
    resource_class.name.underscore.parameterize.pluralize.underscore
  end

  def resource_modulized_name
    resource_class.name.underscore.parameterize.underscore
  end

  private

  def failed_message
    if form_resource.respond_to?(:errors)
      form_resource.errors.full_messages.join("\n")
    else
      'Something went wrong'
    end
  end

  def respond_defaults
    hash = { success: true, login: false }
    if login_status?
      hash[:login] = true
      hash[:current_user] = UserSerializer.new(current_user)
    end
    hash
  end
end
