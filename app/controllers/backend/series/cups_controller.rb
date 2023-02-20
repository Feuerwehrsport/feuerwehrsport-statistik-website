# frozen_string_literal: true

class Backend::Series::CupsController < Backend::BackendController
  backend_actions :destroy

  protected

  def after_destroy
    redirect_to backend_series_round_path(resource.round)
  end
end
