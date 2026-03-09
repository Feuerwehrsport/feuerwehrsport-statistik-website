# frozen_string_literal: true

class Series::AssessmentConfig
  include ActiveModel::Model
  include ActiveModel::Attributes

  SHOW_COLUMNS = {
    'participation_count' => { name: 'Teil.', method: :count },
    'points' => { name: 'Punkte', method: :points },
    'all_points' => { name: 'Punkte', method: :all_points },
    'best_time' => { name: 'Bestzeit', method: :second_best_time },
    'sum_time' => { name: 'Summe', method: :second_sum_time },
  }.freeze

  RANKING_LOGICS = {
    'rank' => { name: 'Platz (kleiner zuerst)' },
    'participation_count' => { name: 'Teilnahmen (mehr zuerst)' },
    'valid_participation_count' => { name: 'Gültige Teilnahmen (mehr zuerst)' },
    'points' => { name: 'Punkte (mehr zuerst)' },
    'points_reverse' => { name: 'Punkte (weniger zuerst)' },
    'all_points' => { name: 'Punkte (mehr zuerst)' },
    'best_time' => { name: 'Beste Zeit (kleiner zuerst)' },
    'sum_time' => { name: 'Summe der Zeiten (kleiner zuerst)' },
    'best_rank' => { name: 'Beste Platzierung (kleiner zuerst)' },
    'best_rank_count' => { name: 'Anzahl der besten Platzierungen (mehr zuerst)' },
  }.freeze

  attribute :key, :string
  validates :key, presence: true

  attribute :disciplines, default: -> { [] }
  validates :disciplines, array: { of: String, min: 1 }

  attribute :name, :string
  validates :name, presence: true

  attribute :calc_participations_count, :integer
  validates :calc_participations_count, numericality: { only_integer: true }, comparison: { greater_than: 0 }

  attribute :min_participations_count, :integer
  validates :min_participations_count, numericality: { only_integer: true }, comparison: { greater_than: 0 }

  attribute :points_for_rank, default: -> { [] }
  validates :points_for_rank, array: { of: Integer }

  attribute :ranking_logic, default: -> { [] }
  validates :ranking_logic, array: { of: String, min: 1, in: RANKING_LOGICS.keys }

  attribute :honor_ranking_logic, default: -> { [] }
  validates :honor_ranking_logic, array: { of: String, in: RANKING_LOGICS.keys }

  attribute :show_columns, default: -> { %w[participation_count points] }
  validates :show_columns, array: { of: String, min: 1, in: SHOW_COLUMNS.keys }

  attribute :penalty_points, :integer, default: nil
  validates :penalty_points, numericality: { only_integer: true }, allow_nil: true

  attr_accessor :round, :entity_key

  delegate :team_assessments, :person_assessments, :full_cup_count, :cups, to: :round

  def initialize(attributes = {})
    filtered = attributes.stringify_keys.slice(*Series::AssessmentConfig.attribute_types.keys)
    super(filtered)

    self.disciplines ||= []
    self.points_for_rank ||= []
    self.ranking_logic ||= []
  end

  def show_columns_config
    show_columns.map { |k| SHOW_COLUMNS[k] }
  end

  def ranking_logic_config
    ranking_logic.map { |k| RANKING_LOGICS[k] }
  end

  def honor_ranking_logic_config
    honor_ranking_logic.map { |k| RANKING_LOGICS[k] }
  end

  def completed?
    @completed ||= full_cup_count == cups.count
  end

  def rows
    @rows ||= begin
      # Sortieren nach Config
      rows = entities.values.sort

      # Plätze vergeben
      calculate_ranks!(rows)

      # Besondere Beachtung der ersten drei Plätze und erneut vergeben
      if honor_ranking_logic.present?
        honor_rows = rows.select { |row| row.rank.present? && row.rank <= 3 }
                         .sort { |row, other| sort(row, other, logic_array: honor_ranking_logic) }
        calculate_ranks!(honor_rows, logic_array: honor_ranking_logic)
        rows.sort! { |row, other| sort(row, other, with_rank: true) }
      end
      rows
    end
  end

  def entities
    entity_key == :team ? teams : people
  end

  def people
    people = {}

    Series::PersonParticipation.where(person_assessment: person_assessments.where(key:)).each do |participation|
      people[participation.entity_id] ||= Series::Person.new(
        config: self, person: participation.person,
      )
      people[participation.entity_id].add_participation(participation)
    end
    people
  end

  def teams
    teams = {}
    Series::TeamParticipation.where(team_assessment: team_assessments.where(key:)).each do |participation|
      teams[participation.entity_id] ||= Series::Team.new(
        config: self, team: participation.team, team_number: participation.team_number,
        team_gender: participation.team_gender
      )
      teams[participation.entity_id].add_participation(participation)
    end
    teams
  end

  def sort(e1, e2, logic_array: ranking_logic, with_rank: false)
    array = logic_array.dup
    array.insert(0, 'rank') if with_rank

    array.each do |logic|
      ret = send("sort_#{logic}", e1, e2)
      return ret if ret != 0
    end
    0
  end

  private

  def calculate_ranks!(rows, logic_array: ranking_logic)
    current_rank = 1
    last_row = nil
    rank = 1

    rows.each do |row|
      if completed? && row.participation_count < min_participations_count
        row.rank = nil
        next
      end

      current_rank = rank unless last_row && sort(row, last_row, logic_array:).zero?
      row.rank = current_rank

      last_row = row
      rank += 1
    end

    rows
  end

  # Platzierung (weniger vor mehr)
  def sort_rank(e1, e2)
    (e1.rank || 999) <=> (e2.rank || 999)
  end

  # Anzahl der Teilnahmen (mehr vor weniger)
  def sort_participation_count(e1, e2)
    e2.ordered_participations.count <=> e1.ordered_participations.count
  end

  # Anzahl der gültigen Teilnahmen (mehr vor weniger)
  def sort_valid_participation_count(e1, e2)
    e2.valid_participations.count <=> e1.valid_participations.count
  end

  # Summe Punkte der gezählten Wettkämpfe (mehr vor weniger)
  def sort_points(e1, e2)
    e2.points <=> e1.points
  end

  # Summe Punkte der gezählten Wettkämpfe (weniger vor mehr)
  def sort_points_reverse(e1, e2)
    e1.points <=> e2.points
  end

  # Summe Punkte der aller Wettkämpfe (mehr vor weniger)
  def sort_all_points(e1, e2)
    e2.all_points <=> e1.all_points
  end

  # Bestzeit (weniger vor mehr)
  def sort_best_time(e1, e2)
    e1.best_time_without_nil <=> e2.best_time_without_nil
  end

  # Summe der Bestzeiten der gezählten Wettkämpfe (weniger vor mehr)
  def sort_sum_time(e1, e2)
    e1.sum_time <=> e2.sum_time
  end

  # Bester Platz (weniger vor mehr)
  def sort_best_rank(e1, e2)
    e1.best_rank <=> e2.best_rank
  end

  # Summe der Besten Ränge (mehr vor weniger)
  def sort_best_rank_count(e1, e2)
    e2.best_rank_count <=> e1.best_rank_count
  end
end
