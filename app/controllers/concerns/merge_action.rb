# frozen_string_literal: true

module MergeAction
  extend ActiveSupport::Concern

  included do
    before_action :assign_instances_for_merge, only: :merge
  end

  def merge
    resource_class.transaction do
      merge_change_log
      EntityMerge.merge!(resource, @correct_resource, always: params[:always].present?)
      clean_cache_and_build_new
      success(resource_modulized_name.to_sym => @correct_resource.reload.decorate,
              resource_name: resource_modulized_name)
    end
  rescue ActiveRecord::ActiveRecordError => e
    failed(message: e.message)
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
end
