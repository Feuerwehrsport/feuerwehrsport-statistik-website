# frozen_string_literal: true

class Api::NationsController < Api::BaseController
  api_actions :show, :index,
              change_log: true

  protected

  def base_collection
    super.reorder(:name)
  end
end
