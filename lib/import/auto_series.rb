class Import::AutoSeries
  RoundConfig = Struct.new(:name, :year, :aggregate_type, :competition_ids, :team_points, :person_points, :options)

  def create_series_competitions(round, cups, assessments, points, type)
    cups.each do |cup|
      assessments.each do |assessment|
        scores = send(:"series_#{type}_participations", cup.competition, assessment.gender, assessment.discipline)
        create_participations(assessment, cup, scores, points)
      end
    end
  end

  def series_team_participations(competition, gender, discipline)
    competition.group_scores.gender(gender).discipline(discipline).best_of_competition(true).sort_by(&:time)
  end

  def series_group_participations(competition, gender, discipline)
    competition.group_assessment(discipline, gender)
  end

  def series_person_participations(competition, gender, discipline)
    competition.scores.gender(gender).discipline(discipline).best_of_competition.sort_by(&:time)
  end
  
  def create_participations(assessment, cup, scores, points)
    rank = 1
    scores.each do |score|
      hash = {
        assessment: assessment, 
        cup: cup, 
        time: score.time, 
        points: points, 
        rank: rank
      }
      if score.is_a?(Score)
        Series::PersonParticipation.create!(hash.merge(person: score.person))
      else
        Series::TeamParticipation.create!(hash.merge(team: score.team, team_number: score.team_number))
      end
      points -= 1 if points > 0
      rank += 1
    end
  end

  def configs
    [
      RoundConfig.new("D-Cup", 2015, "DCup", [876, 754, 731], 10, 30, {}),
      RoundConfig.new("MV-Cup", 2015, "MVCup", [765, 745, 723, 700], 15, 0, {}),
      RoundConfig.new("MV-Steigercup", 2015, "MVCup", [728, 747, 820, 875], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Hinderniscup", 2015, "MVCup", [728, 750, 820, 875], 0, 20, { only: [:hb] }),
      RoundConfig.new("MV-Steigercup", 2014, "MVCup", [460, 498, 555, 575], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Hinderniscup", 2014, "MVCup", [460, 498, 575], 0, 20, { only: [:hb] }),
      RoundConfig.new("MV-Steigercup", 2013, "MVCup", [162, 201, 258, 263], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Hinderniscup", 2013, "MVCup", [162, 201, 267, 258], 0, 20, { only: [:hb] }),
      RoundConfig.new("MV-Steigercup", 2012, "MVCup", [48, 49, 50, 51], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2011, "MVCup", [32, 33, 34], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2010, "MVCup", [64, 65, 66], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2009, "MVCup", [22, 23, 24], 0, 20, { only: [:hl] }),
    ]
  end

  def perform
    Series::Participation.delete_all
    Series::Assessment.delete_all
    Series::Cup.delete_all
    Series::Round.delete_all


    configs.each do |config|
      round = Series::Round.create!(name: config.name, year: config.year)
      cups = config.competition_ids.map do |competition_id|
        Series::Cup.create!(round: round, competition_id: competition_id)
      end
      [:hl, :hb].each do |discipline|
        next if config.options[:only].present? && !discipline.in?(config.options[:only])
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
        create_series_competitions(round, cups, assessments, config.person_points, :person)
      end
      [:gs, :fs, :la].each do |discipline|
        next if config.options[:only].present? && !discipline.in?(config.options[:only])
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
        create_series_competitions(round, cups, assessments, config.team_points, :team)
      end
      [:hl, :hb].each do |discipline|
        next if config.options[:only].present? && !discipline.in?(config.options[:only])
        assessments = []
        [:female, :male].each do |gender|
          if Competition.with_group_assessment.where(id: config.competition_ids).map {|c| c.group_assessment(discipline, gender)}.flatten.present?
            assessments.push Series::TeamAssessment.create!(
              round: round,
              discipline: discipline,
              gender: gender,
              aggregate_type: config.aggregate_type
            )
          end
        end
        create_series_competitions(round, cups, assessments, config.team_points, :group)
      end
    end
  end
end