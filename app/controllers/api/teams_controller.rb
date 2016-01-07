module API
  class TeamsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction
    include CRUD::IndexAction

    before_action :assign_instances_for_merge, only: :merge

    def merge
      begin
        resource_class.transaction do
          resource_instance.merge_to(@correct_team)
          if params[:always].present?
            TeamSpelling.create!(team: @correct_team, name: resource_instance.name, shortcut: resource_instance.shortcut)
          end
          unless resource_instance.reload.destroy
            raise ActiveRecord::ActiveRecordError.new("Could not destroy team with id ##{resource_instance.id}")
          end
        end
      rescue ActiveRecord::ActiveRecordError => error
        failed(message: error.message)
      end
      # todo logging
      success(resource_variable_name.to_sym => @correct_team.reload, resource_name: resource_variable_name)
    end

    protected

    def assign_instances_for_merge
      assign_existing_instance
      authorize! :merge, resource_instance
      self.resource_instance = resource_instance.decorate
      @correct_team = resource_class.find(params[:correct_team_id])
    end

    def create_permitted_attributes
      permitted_attributes.permit(:name, :shortcut, :status)
    end

    def update_permitted_attributes
      permitted_keys = [:latitude, :longitude]
      permitted_keys.push(:name, :shortcut, :status) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
