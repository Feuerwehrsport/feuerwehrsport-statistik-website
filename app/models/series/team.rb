# frozen_string_literal: true

class Series::Team
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Draper::Decoratable

  attr_accessor :config, :team, :team_number, :team_gender, :rank

  delegate :id, to: :team, prefix: true

  def initialize(*)
    @rank = 0
    super
  end

  def add_participation(participation)
    @cups ||= {}
    @cups[participation.cup_id] ||= []
    @cups[participation.cup_id].push(participation)
  end

  def participations_for_cup(cup)
    @cups ||= {}
    (@cups[cup.id] || []).sort_by(&:team_assessment)
  end

  def points_for_cup(cup)
    @cups ||= {}
    @cups[cup.id] ||= []
    @cups[cup.id].sum(&:points)
  end

  def count
    @cups ||= {}
    @cups.values.count
  end

  def all_points
    @cups.values.sum { |cup| cup.sum(&:points) }
  end

  def points
    @points ||= begin
      sum = ordered_participations.sum(&:points)
      if config.penalty_points.nil?
        sum
      else
        fail_points = (config.round.cups.count - count) * config.penalty_points
        sum + fail_points
      end
    end
  end

  def best_time
    @best_time ||= begin
      scores = @cups.values.flatten
      scores.select! { |p| p.team_assessment.discipline == 'la' } if config.disciplines.include?('la')
      scores.map(&:time).min
    end
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
      compare = b.points <=> a.points
      compare.zero? ? a.time <=> b.time : compare
    end.first(config.calc_participations_count)
  end

  def valid_participations
    @valid_participations ||= ordered_participations.select { |part| part.time < Firesport::INVALID_TIME }
  end

  def participation_count
    @cups.values.count
  end

  def <=>(other)
    config.sort(self, other)
  end
end
