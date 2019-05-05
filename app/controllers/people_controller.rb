class PeopleController < ResourceController
  include DatatableSupport
  resource_actions :show, cache: %i[show index]

  %i[female male].each do |gender|
    datatable(:index, :"people_#{gender}", Person, collection: Person.gender(gender).includes(:nation)) do |t|
      t.col(:last_name, class: 'col-20', searchable: :last_name) { |row| row.link_to(:last_name) }
      t.col(:first_name, class: 'col-20', searchable: :first_name) { |row| row.link_to(:first_name) }
      t.col(:nation_flag_with_iso, class: 'col-10')
      t.col(:hb_count, class: 'col-10')
      t.col(:hl_count, class: 'col-10')
      t.col(:la_count, class: 'col-10')
      t.col(:fs_count, class: 'col-10')
      t.col(:gs_count, class: 'col-10') if gender == :female
    end
  end

  def index
    @chart = Chart::PersonIndex.new(context: view_context)
  end

  def show
    super
    @discipline_structs = person_discipline_structs
    @teams = resource.teams.decorate
    @team_structs = @teams.map do |team|
      OpenStruct.new(
        team: team,
        score_count: team.person_scores_count(resource),
        hb: team.scores.low_and_high_hb.where(person: resource).count,
        hl: team.scores.hl.where(person: resource).count,
        gs: team.group_score_participations.gs.where(person: resource).count,
        fs: team.group_score_participations.fs.where(person: resource).count,
        la: team.group_score_participations.la.where(person: resource).count,
      )
    end
    @chart = Chart::PersonShow.new(person: resource, team_structs: @team_structs, context: view_context)
    @series_structs = Series::PersonAssessment.for(resource.id)
    @max_series_cups = @series_structs.values.flatten.map(&:values).flatten.map(&:cups).map(&:count).max
    @person_spellings = resource.person_spellings.official.decorate.to_a
  end

  protected

  def find_collection
    super.includes(:nation)
  end

  private

  def team_mates(discipline)
    team_mates = {}
    resource
      .group_scores
      .discipline(discipline)
      .includes(:person_participations)
      .includes(group_score_category: :competition)
      .decorate
      .each do |score|
      score.person_participations.each do |person_participation|
        next if person_participation.person_id == resource.id

        team_mates[person_participation.person_id] ||= []
        team_mates[person_participation.person_id].push(score)
      end
    end
    team_mates.map do |person_id, scores|
      OpenStruct.new(person: Person.find(person_id).decorate, scores: scores)
    end
  end

  def person_discipline_structs
    disciplines = []

    %i[hb hw hl].each do |discipline|
      scores = resource.scores.where(discipline: discipline)
      next if scores.blank?

      chart_scores = scores.valid.best_of_competition.includes(:competition).sort_by { |s| s.competition.date }
                           .map(&:decorate)
      scores = scores.includes(competition: %i[place event]).decorate
      valid_scores = scores.reject(&:time_invalid?)

      disciplines.push(OpenStruct.new(
                         discipline: discipline,
                         scores: scores,
                         chart_scores: chart_scores,
                         best_time: best_time(scores),
                         average_time: average_time(valid_scores),
                         count: scores.size,
                         valid_scores: valid_scores,
                       ))
    end

    { zk: resource.score_double_events, zw: resource.score_low_double_events }.each do |discipline, scores|
      next if scores.blank?

      chart_scores = scores.includes(:competition).sort_by { |s| s.competition.date }.map(&:decorate)
      scores = scores.includes(competition: %i[place event]).decorate
      valid_scores = scores.reject(&:time_invalid?)

      disciplines.push(OpenStruct.new(
                         discipline: discipline,
                         scores: scores,
                         chart_scores: chart_scores,
                         best_time: best_time(scores),
                         average_time: average_time(valid_scores),
                         count: scores.size,
                         valid_scores: valid_scores,
                       ))
    end

    %i[gs fs la].each do |discipline|
      scores = resource.group_score_participations.where(discipline: discipline)
      next if scores.blank?

      chart_scores = scores.valid.best_of_competition.includes(:competition).sort_by { |s| s.competition.date }
                           .map(&:decorate)
      scores = scores.includes(competition: %i[place event]).includes(:group_score_type).decorate
      valid_scores = scores.reject(&:time_invalid?)

      disciplines.push(OpenStruct.new(
                         discipline: discipline,
                         scores: scores,
                         chart_scores: chart_scores,
                         best_time: best_time(scores),
                         average_time: average_time(valid_scores),
                         count: scores.size,
                         valid_scores: valid_scores,
                         team_mates: team_mates(discipline),
                       ))
    end
    disciplines
  end

  def best_time(scores)
    scores.min_by(&:time).try(:second_time)
  end

  def average_time(valid_scores)
    Firesport::Time.second_time(valid_scores.map(&:time).sum.to_f / valid_scores.size)
  end
end
