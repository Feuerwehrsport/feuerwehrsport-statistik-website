# frozen_string_literal: true

class Calc::PerformanceOfYear < Calc::Base
  attr_accessor :klass, :year, :key, :gender

  def self.get(year)
    [
      new(klass: Calc::PerformanceOfYear::Person, year:, key: :hb, gender: :female),
      new(klass: Calc::PerformanceOfYear::Person, year:, key: :hb, gender: :male),
      new(klass: Calc::PerformanceOfYear::Person, year:, key: :hl, gender: :female),
      new(klass: Calc::PerformanceOfYear::Person, year:, key: :hl, gender: :male),
      new(klass: Calc::PerformanceOfYear::Team, year:, key: :gs, gender: :female),
      new(klass: Calc::PerformanceOfYear::Team, year:, key: :la, gender: :female),
      new(klass: Calc::PerformanceOfYear::Team, year:, key: :la, gender: :male),
    ].select { |performance| performance.entries.present? }
  end

  def entries
    @entries ||= klass.entries(year, key, gender)
  end

  class Base
    attr_reader :scores, :entity
    attr_accessor :rank

    def self.entries(year, key, gender)
      entries = {}
      score_collection(year, key, gender).gender(gender).year(year).each do |score|
        entries[score.entity_id] ||= new(score.entity)
        entries[score.entity_id].scores.push(score.decorate)
      end

      entries.values.sort_by(&:points).each_with_index { |e, i| e.rank = i + 1 }
    end

    def initialize(entity)
      @entity = entity
      @scores = []
    end

    def valid_times
      @valid_times ||= scores.reject(&:time_invalid?)
    end

    def valid_time_sum
      valid_times.sum(&:time)
    end

    def valid_time_count
      valid_times.count
    end

    def invalid_time_count
      scores.to_a.size - valid_time_count
    end

    def valid_time_average
      @valid_time_average ||= valid_time_count > 0 ? valid_time_sum / valid_time_count : Firesport::INVALID_TIME
    end

    def points
      @points ||= begin
        # - 1/23 *x^2+ 10
        sum = 0
        (0..valid_time_count - 1).each do |z|
          subtotal = (-1.0 / 23.0 * (z**2)) + 10
          break if subtotal < 0

          sum += subtotal
        end

        valid_time_average + (invalid_time_count * 15) - sum
      end
    end

    def second_valid_time_average
      Firesport::Time.second_time(valid_time_average)
    end

    def rounded_points
      points.round
    end
  end

  class Team < Base
    def team
      entity
    end

    def self.score_collection(_year, key, _gender)
      GroupScore.regular.includes(group_score_category: { competition: %i[event
                                                                          place] }).includes(:team).discipline(key)
    end
  end

  class Person < Base
    def person
      entity
    end

    def self.score_collection(year, key, gender)
      single_discipline = SingleDiscipline.default_for(key, gender, year)
      Score.german.includes(competition: %i[event place]).includes(:person).where(single_discipline:)
    end
  end
end
