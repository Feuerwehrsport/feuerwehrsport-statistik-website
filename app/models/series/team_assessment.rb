# frozen_string_literal: true

class Series::TeamAssessment < ApplicationRecord
  include Caching::Keys

  belongs_to :round, class_name: 'Series::Round'
  has_many :cups, through: :round, class_name: 'Series::Cup'
  has_many :team_participations, class_name: 'Series::TeamParticipation', dependent: :destroy

  scope :round, ->(round_id) { where(round_id:) }

  schema_validations

  def rows
    @rows ||= calculate_rows
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
    participations.each do |participation|
      entities[participation.entity_id] ||= aggregate_class.new(round, participation.entity)
      entities[participation.entity_id].add_participation(participation)
    end
    entities
  end
end
