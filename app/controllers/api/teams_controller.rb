# frozen_string_literal: true

# read only, used by Feusport (ImportSuggestionsJob)
class Api::TeamsController < Api::BaseController
  api_actions :index

  protected

  def base_collection
    super.reorder(:name)
  end
end
