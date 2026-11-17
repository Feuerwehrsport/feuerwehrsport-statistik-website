# frozen_string_literal: true

# read only, used by Feusport (ImportSuggestionsJob)
class Api::Series::RoundsController < Api::BaseController
  api_actions :index

  protected

  def base_collection
    super.includes(:kind)
  end
end
