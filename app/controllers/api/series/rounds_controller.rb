# frozen_string_literal: true

class Api::Series::RoundsController < Api::BaseController
  api_actions :show, :index

  protected

  def base_collection
    super.includes(:kind)
  end
end
