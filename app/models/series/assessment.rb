# frozen_string_literal: true

class Series::Assessment < ApplicationRecord
  include Genderable
  include Caching::Keys

  belongs_to :round, class_name: 'Series::Round'
  has_many :cups, through: :round, class_name: 'Series::Cup'
  has_many :participations, class_name: 'Series::Participation', dependent: :destroy

  scope :with_person, ->(person_id) do
                        joins(:participations).where(series_participations: { person_id: }).distinct
                      end
  scope :round, ->(round_id) { where(round_id:) }

  validates :discipline, :gender, presence: true
  schema_validations

  def rows
    @rows ||= calculate_rows
  end

  def aggregate_class
    @aggregate_class ||= Firesport::Series::Handler.person_class_for(round.aggregate_type)
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
