# frozen_string_literal: true

class GroupScoreTypeDecorator < AppDecorator
  delegate :to_s, to: :name

  def searchable_name
    "#{discipline}, #{self}"
  end
end
