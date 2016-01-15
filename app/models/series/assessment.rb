module Series
  class Assessment < ActiveRecord::Base
    include Genderable
    include Caching::Keys

    belongs_to :round
    has_many :cups, through: :round
    has_many :participations

    scope :with_person, -> (person_id) { joins(:participations).where(series_participations: { person_id: person_id }).uniq }

    validates :round, :discipline, :gender, presence: true

    def rows
      @rows ||= calculate_rows
    end

    def aggregate_class
      @aggregate_class ||= "Series::ParticipationRows::#{round.aggregate_type}".constantize
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
        entities[participation.entity_id] ||= aggregate_class.new(participation.entity)
        entities[participation.entity_id].add_participation(participation)
      end
      entities
    end
  end
end