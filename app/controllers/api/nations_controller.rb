# frozen_string_literal: true

class API::NationsController < API::BaseController
  api_actions :show, :index,
              change_log: true

  protected

  def base_collection
    super.reorder(:name)
  end
end
