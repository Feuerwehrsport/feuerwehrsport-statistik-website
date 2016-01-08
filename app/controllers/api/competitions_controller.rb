module API
  class CompetitionsController < BaseController
    include CRUD::ShowAction
    include CRUD::UpdateAction

    protected

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:name) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
