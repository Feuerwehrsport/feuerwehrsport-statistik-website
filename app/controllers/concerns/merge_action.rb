module MergeAction
  extend ActiveSupport::Concern

  included do
    before_action :assign_instances_for_merge, only: :merge
  end

  def merge
    begin
      resource_class.transaction do
        resource_instance.merge_to(@correct_resource_instance)
        if params[:always].present?
          "#{resource_class}Spelling".constantize.create_from(@correct_resource_instance, resource_instance)
        end
        unless resource_instance.reload.destroy
          raise ActiveRecord::ActiveRecordError.new("Could not destroy #{resource_variable_name} with id ##{resource_instance.id}")
        end
        # todo logging
        success(resource_variable_name.to_sym => @correct_resource_instance.reload.decorate, resource_name: resource_variable_name)
      end
    rescue ActiveRecord::ActiveRecordError => error
      failed(message: error.message)
    end
  end

  protected

  def assign_instances_for_merge
    assign_existing_instance
    self.resource_instance = resource_instance.decorate
    @correct_resource_instance = resource_class.find(params[correct_variable_name]).decorate
    authorize!(:merge, resource_instance.object)
    authorize!(:merge, @correct_resource_instance.object)
  end

  def correct_variable_name
    :"correct_#{resource_variable_name}_id"
  end
end