class PeopleController < ResourceController
  cache_actions :index, :show

  def index
    @people = {}
    [:female, :male].each do |gender|
      @people[gender] = Person.gender(gender).includes(:nation).with_score_count.decorate.to_a
    end
    @chart = Chart::PersonIndex.new(people: @people)
  end

  def show
    @person = Person.find(params[:id]).decorate
    @discipline_structs = person_discipline_structs
    @teams = @person.teams.decorate
    @team_structs = @teams.map do |team|
      OpenStruct.new(
        team: team,
        score_count: team.person_scores_count(@person),
        hb:  team.scores.hb.where(person: @person).count,
        hl:  team.scores.hl.where(person: @person).count,
        gs:  team.group_score_participations.gs.where(person: @person).count,
        fs:  team.group_score_participations.fs.where(person: @person).count,
        la:  team.group_score_participations.la.where(person: @person).count,
      )
    end
    @chart = Chart::PersonShow.new(person: @person, team_structs: @team_structs)
    @series_structs = Series::PersonAssessment.for(@person.id)
    @max_series_cups = @series_structs.values.flatten.map(&:values).flatten.map(&:cups).map(&:count).max
    @page_title = "#{@person.full_name} - Wettkämpfer"
  end

  private

  def team_mates(discipline)
    team_mates = {}
    @person.
      group_scores.
      discipline(discipline).
      includes(:person_participations).
      includes(group_score_category: :competition).
      decorate.
      each do |score|
      score.person_participations.each do |person_participation|
        next if person_participation.person_id == @person.id
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
    
    [:hb, :hl].each do |discipline|
      scores = @person.scores.where(discipline: discipline)
      if scores.count > 0
        chart_scores = scores.valid.best_of_competition.includes(:competition).decorate.sort_by {|s| s.competition.date}
        scores = scores.includes(competition: [:place, :event]).decorate
        valid_scores = scores.reject(&:time_invalid?)

        disciplines.push(OpenStruct.new(
          discipline: discipline, 
          scores: scores,
          chart_scores: chart_scores,
          best_time: best_time(scores),
          average_time: average_time(valid_scores),
          count: scores.size,
          valid_scores: valid_scores
        ))
      end
    end

    scores = @person.score_double_events
    if scores.count > 0
      chart_scores = scores.includes(:competition).decorate.sort_by {|s| s.competition.date}
      scores = scores.includes(competition: [:place, :event]).decorate
      valid_scores = scores.reject(&:time_invalid?)

      disciplines.push(OpenStruct.new(
        discipline: :zk, 
        scores: scores,
        chart_scores: chart_scores,
        best_time: best_time(scores),
        average_time: average_time(valid_scores),
        count: scores.size,
        valid_scores: valid_scores
      ))
    end

    [:gs, :fs, :la].each do |discipline|
      scores = @person.group_score_participations.where(discipline: discipline)
      if scores.count > 0
        chart_scores = scores.valid.best_of_competition.includes(:competition).decorate.sort_by {|s| s.competition.date}
        scores = scores.includes(competition: [:place, :event]).includes(:group_score_type).decorate
        valid_scores = scores.reject(&:time_invalid?)

        disciplines.push(OpenStruct.new(
          discipline: discipline, 
          scores: scores,
          chart_scores: chart_scores,
          best_time: best_time(scores),
          average_time: average_time(valid_scores),
          count: scores.size,
          valid_scores: valid_scores,
          team_mates: team_mates(discipline)
        ))
      end
    end
    disciplines
  end

  def best_time(scores)
    scores.sort_by(&:time).first.try(:second_time)
  end

  def average_time(valid_scores)
    ApplicationDecorator.calculate_second_time(valid_scores.map(&:time).sum.to_f/valid_scores.size)
  end
end
