# frozen_string_literal: true

class EventsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def show
    @competitions = resource.competitions.includes(:place).decorate
  end

  protected

  def find_collection
    super.competition_count
  end
end
