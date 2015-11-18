class Test


def create_series_competitions(round, cups, assessments, points, type)
  cups.each do |cup|
    assessments.each do |assessment|
      send(:"create_series_#{type}_participations", cup.competition, assessment, points, cup)
    end
  end
end

def create_series_team_participations(competition, assessment, points, cup)
  rank = 1
  competition.group_scores.gender(assessment.gender).discipline(assessment.discipline).best_of_competition(true).sort_by(&:time).each do |score|
    Series::TeamParticipation.create!(
      assessment: assessment, 
      cup: cup, 
      team: score.team, 
      team_number: score.team_number, 
      time: score.time, 
      points: points, 
      rank: rank
    )
    points -= 1 if points > 0
    rank += 1
  end
end

def create_series_group_participations(competition, assessment, points, cup)
  rank = 1
  competition.group_assessment(assessment.discipline, assessment.gender).each do |score|
    Series::TeamParticipation.create!(
      assessment: assessment, 
      cup: cup, 
      team: score.team, 
      team_number: score.team_number, 
      time: score.time, 
      points: points, 
      rank: rank
    )
    points -= 1 if points > 0
    rank += 1
  end
end

def create_series_person_participations(competition, assessment, points, cup)
  rank = 1
  competition.scores.gender(assessment.gender).discipline(assessment.discipline).best_of_competition.sort_by(&:time).each do |score|
    Series::PersonParticipation.create!(
      assessment: assessment, 
      cup: cup, 
      person: score.person,
      time: score.time,
      points: points, 
      rank: rank
    )
    points -= 1 if points > 0
    rank += 1
  end
end

RoundConfig = Struct.new(:name, :year, :aggregate_type, :genders, :competition_ids)
def foo
  Series::Participation.delete_all
Series::Assessment.delete_all
Series::Cup.delete_all
Series::Round.delete_all


configs = [
  RoundConfig.new("D-Cup", 2015, "DCup", [:female, :male], [876, 754, 731]),
]

configs.each do |config|
  round = Series::Round.create!(name: config.name, year: config.year)
  cups = config.competition_ids.map do |competition_id|
    Series::Cup.create!(round: round, competition_id: competition_id)
  end
  [:hl, :hb].each do |discipline|
    assessments = []
    [:female, :male].each do |gender|
      if Score.where(competition_id: config.competition_ids).discipline(discipline).gender(gender).present?
        assessments.push Series::PersonAssessment.create!(
          round: round,
          discipline: discipline, 
          gender: gender, 
          aggregate_type: config.aggregate_type
        )
      end
    end
    create_series_competitions(round, cups, assessments, 30, :person)
  end
  [:gs, :fs, :la].each do |discipline|
    assessments = []
    [:female, :male].each do |gender|
      if GroupScore.
        discipline(discipline).
        gender(gender).
        joins(:group_score_category).
        where(group_score_categories: { competition_id: config.competition_ids }).
        present?
        assessments.push Series::TeamAssessment.create!(
          round: round,
          discipline: discipline, 
          gender: gender, 
          aggregate_type: config.aggregate_type
        )
      end
    end
    create_series_competitions(round, cups, assessments, 10, :team)
  end
  [:hl, :hb].each do |discipline|
    binding.pry
    assessments = []
    [:female, :male].each do |gender|
      if Competition.where(id: config.competition_ids).map {|c| c.group_assessment(discipline, gender)}.flatten.present?
        assessments.push Series::TeamAssessment.create!(
          round: round,
          discipline: discipline,
          gender: gender,
          aggregate_type: config.aggregate_type
        )
      end
    end
    create_series_competitions(round, cups, assessments, 10, :group)
  end
end
end
end