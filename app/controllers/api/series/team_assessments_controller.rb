class API::Series::TeamAssessmentsController < API::BaseController
  api_actions :index

  protected

  def base_collection
    if params[:round_id].present?
      super.round(params[:round_id])
    else
      super
    end
  end
end
