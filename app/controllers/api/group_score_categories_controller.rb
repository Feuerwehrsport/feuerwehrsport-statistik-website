# frozen_string_literal: true

class Api::GroupScoreCategoriesController < Api::BaseController
  api_actions :create, :index,
              change_log: true,
              default_form: %i[name group_score_type_id competition_id]

  protected

  def base_collection
    super_collection = super
    super_collection = super_collection.discipline(params[:discipline]) if params[:discipline].present?
    if params[:competition_id].present?
      super_collection = super_collection.where(competition_id: params[:competition_id])
    end
    super_collection
  end
end
