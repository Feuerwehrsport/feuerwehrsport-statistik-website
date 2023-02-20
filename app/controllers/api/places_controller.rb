# frozen_string_literal: true

class Api::PlacesController < Api::BaseController
  api_actions :create, :show, :index, :update,
              change_log: true,
              create_form: [:name],
              update_form: %i[latitude longitude]

  protected

  def base_collection
    super.reorder(:name)
  end
end
