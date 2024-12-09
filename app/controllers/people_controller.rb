# frozen_string_literal: true

class PeopleController < ResourceController
  include DatatableSupport
  resource_actions :show, cache: %i[show index]

  Genderable::GENDER_KEYS.each do |gender|
    datatable(:index, :"people_#{gender}", Person, collection: Person.gender(gender).includes(:nation)) do |t|
      t.col(:last_name, class: 'col-20', searchable: :last_name) { |row| row.link_to(:last_name) }
      t.col(:first_name, class: 'col-20', searchable: :first_name) { |row| row.link_to(:first_name) }
      t.col(:nation_flag_with_iso, class: 'col-10', sortable: { nation: :name })
      t.col(:hb_count, class: 'col-10')
      t.col(:hl_count, class: 'col-10')
      t.col(:la_count, class: 'col-10')
      t.col(:fs_count, class: 'col-10')
      t.col(:gs_count, class: 'col-10') if gender == :female
    end
  end

  def show
    super
    @teams = resource.teams.decorate
    @team_structs = @teams.map do |team|
      {
        team:,
        score_count: team.person_scores_count(resource),
        hb: team.scores.hb.where(person: resource).count,
        hl: team.scores.hl.where(person: resource).count,
        gs: team.group_score_participations.gs.where(person: resource).count,
        fs: team.group_score_participations.fs.where(person: resource).count,
        la: team.group_score_participations.la.where(person: resource).count,
      }
    end
    @series_structs = Series::PersonAssessment.for(resource.id)
    @max_series_cups = @series_structs.values.flatten.map(&:values).flatten.map { |series| series.cups.count }.max
    @person_spellings = resource.person_spellings.official.decorate.to_a
  end

  protected

  def find_collection
    super.includes(:nation)
  end
end
