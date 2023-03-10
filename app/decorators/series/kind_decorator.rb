# frozen_string_literal: true

class Series::KindDecorator < AppDecorator
  decorates_association :rounds
  delegate :to_s, to: :name
end
