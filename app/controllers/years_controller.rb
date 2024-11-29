# frozen_string_literal: true

class YearsController < ResourceController
  resource_actions :show, :index, cache: %i[show index best_performance best_scores]

  def show
    @competitions = @year.competitions.includes(:place, :event).decorate
  end

  def best_performance
    assign_resource
  end

  def best_scores
    assign_resource
  end

  protected

  def find_collection
    super.competition_count
  end
end
