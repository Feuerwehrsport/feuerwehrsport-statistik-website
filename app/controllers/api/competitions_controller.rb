module API
  class CompetitionsController < BaseController
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction

    protected

    def resource_instance_show_object
      ExtendedCompetitionSerializer.new(resource_instance)
    end

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:name) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
