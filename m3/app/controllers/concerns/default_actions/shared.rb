# frozen_string_literal: true

module DefaultActions::Shared
  extend ActiveSupport::Concern
  included do
    helper_method :paginate?
    helper_method :resource_params_name
  end

  protected

  def assign_collection
    self.collection = find_collection
    if collection.respond_to?(:accessible_by)
      self.collection = collection.accessible_by(current_ability, action_name.to_sym)
    end
    self.collection = m3_filter_structure.filter_collection(collection, resource_class: resource_class)
    self.collection = m3_index_structure.order_collection(collection, resource_class: resource_class)
    self.collection = collection.paginate(page: paginate_page, per_page: page_size) if paginate?
  end

  def assign_new_resource
    self.resource = build_resource
    self.form_resource = build_resource
  end

  def assign_resource
    self.resource = find_resource
    self.form_resource = find_resource
  end

  def preauthorize_action
    authorize!(action_name.to_sym, resource_class)
  end

  def authorize_action
    authorize!(action_name.to_sym, resource) if resource && (!resource.respond_to?(:persisted?) || resource.persisted?)
  end

  def resource_params_name
    resource_class.model_name.param_key
  end

  def default_error_message
    t3(:invalid_resource, scope: :errors)
  end

  def paginate?
    !request.format.to_sym.in?(m3_index_export_formats) &&
      request.format != :json &&
      collection.respond_to?(:paginate)
  end

  def paginate_page
    params[:page].presence&.to_i
  end

  def page_size
    WillPaginate.per_page
  end

  def log_active_record_errors(_action, record)
    return unless record.respond_to?(:errors) && record.errors.is_a?(ActiveModel::Errors)

    logger.debug do
      "[M3] Update failed due to errors for resource class #{record.class.name}:\n" +
        record.errors.messages.map { |key, value| "     #{key}: #{value.join(';')}" }.join("\n")
    end
  end
end
