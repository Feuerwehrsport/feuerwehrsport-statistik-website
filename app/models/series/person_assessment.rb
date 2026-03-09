# frozen_string_literal: true

class Series::PersonAssessment < ApplicationRecord
  include Caching::Keys

  belongs_to :round, class_name: 'Series::Round'
  has_many :cups, through: :round, class_name: 'Series::Cup'
  has_many :person_participations, class_name: 'Series::PersonParticipation', dependent: :destroy

  scope :with_person, ->(person_id) do
                        joins(:person_participations).where(series_person_participations: { person_id: }).distinct
                      end
  scope :round, ->(round_id) { where(round_id:) }

  schema_validations

  PersonRound = Struct.new(:assessment, :round, :cups, :row)

  def self.for(person_id)
    assessment_structs = {}
    with_person(person_id)
      .includes(round: :kind)
      .order(Arel.sql('series_kinds.name, series_rounds.year DESC, series_person_assessments.discipline'))
      .decorate.each do |assessment|
      row = assessment.rows.find { |r| r.person_id == person_id }
      next if row.rank.nil?

      assessment_structs[assessment.round.kind.name] ||= {}
      assessment_structs[assessment.round.kind.name][assessment.round.year] ||= []
      assessment_structs[assessment.round.kind.name][assessment.round.year].push(PersonRound.new(
                                                                                   assessment,
                                                                                   assessment.round,
                                                                                   assessment.round.cups,
                                                                                   row,
                                                                                 ))
    end
    assessment_structs
  end

  delegate :rows, :name, to: :config

  def config
    round.person_assessments_configs.find { |c| c.key == key }
  end

  protected

  def calculate_rows
    Caching::Cache.fetch(caching_key(:calculate_rows)) do
      @rows = entities.values.sort
      @rows.each { |row| row.calculate_rank!(@rows) }
    end
  end

  def entities
    entities = {}
    person_participations.each do |participation|
      entities[participation.entity_id] ||= aggregate_class.new(round, participation.entity)
      entities[participation.entity_id].add_participation(participation)
    end
    entities
  end
end
