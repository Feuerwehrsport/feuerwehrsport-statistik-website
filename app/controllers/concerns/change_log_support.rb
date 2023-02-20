# frozen_string_literal: true

module ChangeLogSupport
  extend ActiveSupport::Concern

  included do
    before_action :save_attributes_for_logging, only: %i[create update destroy]
  end

  protected

  def save_attributes_for_logging
    @logging_attributes_before = hash_for_logging
  end

  def after_create
    perform_logging
    super
  end

  def after_update
    perform_logging
    super
  end

  def after_destroy
    perform_logging
    super
  end

  def hash_for_logging(object = resource)
    serializer_for_object(object).as_json
  end

  def perform_logging(hash = {})
    ChangeLog.create(change_log_default_hash.merge(hash))
  end

  def change_log_default_hash
    change_log_hash = {
      model_class: resource_class,
      user: current_user,
      action: params[:log_action].presence || "#{action_name}-#{resource_class.name.parameterize}",
    }
    change_log_hash[:after_hash] = hash_for_logging if action_name != 'destroy'
    change_log_hash[:before_hash] = @logging_attributes_before if action_name.in?(%w[update destroy])
    change_log_hash
  end
end
