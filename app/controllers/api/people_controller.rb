module API
  class PeopleController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction
    include MergeAction

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:first_name, :last_name, :gender, :nation_id)
    end

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:first_name, :last_name, :nation_id) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end

    def base_collection
      if params[:gender].present?
        super.gender(params[:gender])
      else
        super
      end
    end
  end
end
