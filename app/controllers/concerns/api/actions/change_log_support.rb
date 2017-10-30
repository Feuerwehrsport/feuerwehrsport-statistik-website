module API::Actions::ChangeLogSupport
  extend ActiveSupport::Concern

  included do
    before_action :save_attributes_for_logging, only: %i[create update destroy]
  end

  protected

  def save_attributes_for_logging
    @logging_attributes_before = hash_for_logging
  end

  def save_instance
    saved = super
    perform_logging if saved
    saved
  end

  def destroy_instance
    destroyed = super
    perform_logging if destroyed
    destroyed
  end

  def hash_for_logging(object = resource)
    serializer_for_object(object).as_json
  end

  def perform_logging(hash = {})
    ChangeLog.create(change_log_default_hash.merge(hash))
  end

  def change_log_default_hash
    change_log_hash = {
      after_hash: hash_for_logging,
      model_class: resource_class,
      user: current_user,
      action_name: action_name,
      log_action: params[:log_action],
    }
    change_log_hash[:before_hash] = @logging_attributes_before if action_name == 'update'
    change_log_hash
  end
end
