# frozen_string_literal: true

class API::GroupScoreTypesController < API::BaseController
  api_actions :create, :index,
              change_log: true,
              default_form: %i[name discipline]

  protected

  def base_collection
    super_collection = super
    super_collection = super_collection.where(discipline: params[:discipline]) if params[:discipline].present?
    super_collection
  end
end
