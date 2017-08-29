class Series::Round < ActiveRecord::Base
  include Caching::Keys
  include Series::Participationable

  has_many :cups, class_name: 'Series::Cup'
  has_many :assessments, class_name: 'Series::Assessment'
  has_many :participations, through: :assessments, class_name: 'Series::Participation'

  validates :name, :year, :aggregate_type, presence: true

  default_scope -> { order(year: :desc, name: :asc) }
  scope :cup_count, -> do
    select("#{table_name}.*, COUNT(#{Series::Cup.table_name}.id) AS cup_count").
    joins(:cups).
    group("#{table_name}.id")
  end
  scope :with_team, -> (team_id, gender) do
    joins(:participations).where(series_participations:  { team_id: team_id }).merge(Series::TeamAssessment.gender(gender)).uniq
  end

  def disciplines
    assessments.pluck(:discipline).uniq.sort
  end

  def team_assessment_rows(gender, cache=true)
    @team_assessment_rows ||= calculate_rows(cache)
    @team_assessment_rows[gender]
  end

  def aggregate_class
    @aggregate_class ||= Firesport::Series::Handler.team_class_for(aggregate_type)
  end

  def self.for_team(team_id, gender)
    round_structs = {}
    Series::Round.with_team(team_id, gender).decorate.each do |round|
      round_structs[round.name] ||= []
      round.team_assessment_rows(gender).select { |r| r.team.id == team_id }.each do |row|
        next if row.rank.nil?
        round_structs[round.name].push OpenStruct.new(
          round: round,
          cups: round.cups,
          row: row.decorate,
          team_number: row.team_number,
        )
      end
      round_structs.delete(round.name) if round_structs[round.name].empty?
    end
    round_structs
  end

  def cups_left
    full_cup_count - cup_count
  end

  protected

  def calculate_rows(cache)
    Caching::Cache.fetch(caching_key(:calculate_rows), force: !cache) do
      rows = {}
      [:female, :male].each do |gender|
        rows[gender] = teams(gender).values.sort
        rows[gender].each { |row| row.calculate_rank!(rows[gender]) }
        rows[gender].each { |row| aggregate_class.special_sort!(rows[gender]) }
      end
      rows
    end
  end

  def teams(gender)
    teams = {}
    Series::TeamParticipation.where(assessment: assessments.gender(gender)).each do |participation|
      teams[participation.entity_id] ||= aggregate_class.new(participation.team, participation.team_number)
      teams[participation.entity_id].add_participation(participation)
    end
    teams
  end
end
