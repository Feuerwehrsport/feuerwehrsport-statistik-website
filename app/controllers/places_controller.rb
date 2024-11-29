# frozen_string_literal: true

class PlacesController < ResourceController
  resource_actions :show, :index, cache: %i[show index]
  map_support_at :show, :index

  def show
    @competitions = resource.competitions.includes(:event).decorate
  end

  protected

  def find_collection
    super.competition_count
  end
end
