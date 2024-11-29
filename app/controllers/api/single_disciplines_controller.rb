# frozen_string_literal: true

class Api::SingleDisciplinesController < Api::BaseController
  api_actions :index

  protected

  def base_collection
    super_collection = super.reorder(:name)
    super_collection = super_collection.where(key: params[:key]) if params[:key].present?
    super_collection
  end
end
