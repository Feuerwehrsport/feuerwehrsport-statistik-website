# frozen_string_literal: true

class Api::Series::TeamAssessmentsController < Api::BaseController
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
