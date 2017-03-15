class API::PeopleController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::IndexAction
  include API::CRUD::UpdateAction
  include API::CRUD::ChangeLogSupport
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