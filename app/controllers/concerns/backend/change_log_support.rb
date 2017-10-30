module Backend::ChangeLogSupport
  extend ActiveSupport::Concern
  include SerializerSupport

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

  def hash_for_logging
    serializer_for_object(@resource_instance_decorated).as_json
  end

  def perform_logging(hash = {})
    ChangeLog.create!(change_log_default_hash.merge(hash))
  end

  def change_log_default_hash
    change_log_hash = {
      model_class: resource_class,
      user: current_admin_user,
      action_name: action_name,
    }
    change_log_hash[:after_hash] = hash_for_logging if action_name != 'destroy'
    change_log_hash[:before_hash] = @logging_attributes_before if action_name.in?(%w[update destroy])
    change_log_hash
  end
end
