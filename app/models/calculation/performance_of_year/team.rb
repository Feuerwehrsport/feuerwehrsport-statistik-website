# frozen_string_literal: true

class Calculation::PerformanceOfYear::Team < Calculation::PerformanceOfYear::Base
  def team
    entity
  end

  def self.score_collection
    GroupScore.regular.includes(group_score_category: { competition: %i[event place] }).includes(:team)
  end
end
