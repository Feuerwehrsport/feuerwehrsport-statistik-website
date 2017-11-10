class API::PeopleController < API::BaseController
  api_actions :create, :show, :index, :update,
              change_log: true,
              create_form: %i[first_name last_name gender nation_id],
              update_form: %i[first_name last_name nation_id]
  include MergeAction

  protected

  def base_collection
    if params[:gender].present?
      super.reorder(:last_name, :first_name).gender(params[:gender])
    else
      super
    end
  end
end
