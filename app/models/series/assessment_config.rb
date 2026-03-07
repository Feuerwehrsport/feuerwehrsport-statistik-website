# frozen_string_literal: true

class Series::AssessmentConfig
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :key, :string
  validates :key, presence: true

  attribute :disciplines, default: -> { [] }
  validates :disciplines, presence: true

  attribute :name, :string
  validates :name, presence: true

  attribute :calc_participations_count, :integer
  validates :calc_participations_count, numericality: { only_integer: true }, comparison: { greater_than: 0 }

  attribute :min_participations_count, :integer
  validates :min_participations_count, numericality: { only_integer: true }, comparison: { greater_than: 0 }

  attribute :points_for_rank, default: -> { [] }
  validates :points_for_rank, presence: true

  attribute :ranking_logic, default: -> { [] }
  validates :ranking_logic, presence: true

  attribute :honor_ranking_logic, default: -> { [] }
  validates :honor_ranking_logic, presence: true

  attr_accessor :round, :entity_key

  delegate :team_assessments, :person_assessments, :full_cup_count, :cups, to: :round

  def initialize(attributes = {})
    filtered = attributes.stringify_keys.slice(*Series::AssessmentConfig.attribute_types.keys)
    super(filtered)

    self.disciplines ||= []
    self.points_for_rank ||= []
    self.ranking_logic ||= []
  end
end
