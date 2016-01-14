module API
  class PeopleController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction
    include MergeAction

    protected

    def create_permitted_attributes
      super.permit(:first_name, :last_name, :gender, :nation_id)
    end

    def update_permitted_attributes
      super.permit(:first_name, :last_name, :nation_id)
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
