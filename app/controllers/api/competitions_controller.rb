module API
  class CompetitionsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction

    protected

    def resource_instance_show_object
      ExtendedCompetitionSerializer.new(resource_instance)
    end

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:name, :place_id, :event_id, :date)
    end

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:name, :score_type_id) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
