# frozen_string_literal: true

module Series::EntitySupport
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Draper::Decoratable

    attr_accessor :config, :rank, :round
  end

  def initialize(*)
    @rank = 0
    super
  end

  def add_participation(participation)
    @cups ||= {}
    @cups[participation.cup_id] ||= []
    @cups[participation.cup_id].push(participation)
  end

  def count
    @cups ||= {}
    @cups.values.count
  end

  def all_points
    @cups.values.sum { |cup| cup.sum(&:points_with_correction) }
  end

  def best_time_without_nil
    best_time || (Firesport::INVALID_TIME + 1)
  end

  def sum_time
    @sum_time ||= begin
      sum = ordered_participations.sum(&:time)
      [sum, Firesport::INVALID_TIME].min
    end
  end

  def best_rank
    @cups.values.flatten.map(&:rank).min
  end

  def best_rank_count
    @cups.values.flatten.map(&:rank).count { |r| r == best_rank }
  end

  def ordered_participations
    @ordered_participations ||= @cups.values.map(&:first).sort do |a, b|
      compare = b.points_with_correction <=> a.points_with_correction
      compare.zero? ? a.time <=> b.time : compare
    end.first(config.calc_participations_count)
  end

  def participation_count
    @cups.values.count
  end

  def valid_participations
    @valid_participations ||= ordered_participations.select { |part| part.time < Firesport::INVALID_TIME }
  end

  def <=>(other)
    config.sort(self, other)
  end

  def storage_support_get(position)
    case position.key
    when :rank
      "#{rank}."
    when :rank_with_rank
      "#{rank}. Platz"
    when :rank_with_rank2
      "den #{rank}. Platz"
    when :rank_without_dot
      rank.to_s
    when :result_name
      round.name
    else
      super
    end
  end
end
