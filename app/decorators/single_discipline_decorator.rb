# frozen_string_literal: true

class SingleDisciplineDecorator < AppDecorator
  decorates_association :scores
  delegate :to_s, to: :name
end
