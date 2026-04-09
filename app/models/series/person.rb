# frozen_string_literal: true

class Series::Person
  include Series::EntitySupport

  attr_accessor :person

  delegate :id, to: :person, prefix: true

  def participation_for_cup(cup)
    @cups ||= {}
    (@cups[cup.id] || []).first
  end

  def points_for_cup(cup)
    @cups ||= {}
    @cups[cup.id] ||= []
    @cups[cup.id].sum(&:points_with_correction)
  end

  def points
    @points ||= ordered_participations.sum(&:points_with_correction)
  end

  def best_time
    @best_time ||= @cups.values.flatten.map(&:time).min
  end
end
