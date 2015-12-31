module API
  class PeopleController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:first_name, :last_name, :gender, :nation_id)
    end

    def resource_collection
      if params[:gender].present?
        super.gender(params[:gender])
      else
        super
      end
    end
  end
end
