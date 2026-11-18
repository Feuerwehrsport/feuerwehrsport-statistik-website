# frozen_string_literal: true

class PeopleController < ResourceController
  DISCIPLINE_KEYS = %i[hb hl gs fs la].freeze

  include DatatableSupport

  resource_actions :show, cache: %i[show index]

  Genderable::GENDER_KEYS.each do |gender|
    datatable(:index, :"people_#{gender}", Person, collection: Person.gender(gender).includes(:nation)) do |t|
      t.col(:last_name, class: 'col-w-20', searchable: :last_name) { |row| row.link_to(:last_name) }
      t.col(:first_name, class: 'col-w-20', searchable: :first_name) { |row| row.link_to(:first_name) }
      t.col(:nation_flag_with_iso, class: 'col-w-10', sortable: { nation: :name })
      t.col(:hb_count, class: 'col-w-10')
      t.col(:hl_count, class: 'col-w-10')
      t.col(:la_count, class: 'col-w-10')
      t.col(:fs_count, class: 'col-w-10')
      t.col(:gs_count, class: 'col-w-10') if gender == :female
    end
  end

  def show
    super
    @teams = resource.teams.decorate
    team_counts = resource.team_discipline_counts
    @team_structs = @teams.map do |team|
      counts = team_counts.fetch(team.id, {})
      { team:, score_count: counts.values.sum, **DISCIPLINE_KEYS.index_with { |key| counts.fetch(key, 0) } }
    end
    @series_structs = Series::PersonAssessment.for(resource.id)
    @max_series_cups = @series_structs.values.flatten.map(&:values).flatten.map { |series| series.cups.size }.max
    @person_spellings = resource.person_spellings.official.decorate.to_a
    @score_count = resource.scores.count + resource.group_score_participations.count
    competition_ids = (resource.scores.distinct.pluck(:competition_id) +
                       resource.group_score_participations.distinct.pluck(:competition_id)).uniq
    @competition_count = competition_ids.count
    NumberedTeamNames.preload_team_numbers(competition_ids)
  end

  protected

  def find_collection
    super.includes(:nation)
  end
end
