class Series::Assessment < ActiveRecord::Base
  include Genderable
  include Caching::Keys

  belongs_to :round, class_name: 'Series::Round'
  has_many :cups, through: :round, class_name: 'Series::Cup'
  has_many :participations, class_name: 'Series::Participation'

  scope :with_person, ->(person_id) { joins(:participations).where(series_participations: { person_id: person_id }).uniq }
  scope :round, ->(round_id) { where(round_id: round_id) }

  validates :round, :discipline, :gender, presence: true

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
