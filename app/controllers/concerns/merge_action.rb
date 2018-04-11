module MergeAction
  extend ActiveSupport::Concern

  included do
    before_action :assign_instances_for_merge, only: :merge
  end

  def merge
    resource_class.transaction do
      resource.merge_to(@correct_resource)
      "#{resource_class}Spelling".constantize.create_from(@correct_resource, resource) if params[:always].present?
      merge_change_log
      create_entity_merge
      unless resource.reload.destroy
        raise ActiveRecord::ActiveRecordError, "Could not destroy #{resource_variable_name} with id ##{resource.id}"
      end
      clean_cache_and_build_new
      success(resource_modulized_name.to_sym => @correct_resource.reload.decorate,
              resource_name: resource_modulized_name)
    end
  rescue ActiveRecord::ActiveRecordError => error
    failed(message: error.message)
  end

  protected

  def merge_change_log
    perform_logging(
      after_hash: hash_for_logging(@correct_resource),
      before_hash: hash_for_logging,
    )
  end

  def assign_instances_for_merge
    assign_resource
    @correct_resource = base_collection.find(params[correct_variable_name])
    authorize!(:merge, resource)
    authorize!(:merge, @correct_resource)
  end

  def correct_variable_name
    :"correct_#{resource_modulized_name}_id"
  end

  def create_entity_merge
    EntityMerge.create!(source: resource, target: @correct_resource)
  end
end
