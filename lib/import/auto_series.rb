class Import::AutoSeries
  RoundConfig = Struct.new(:name, :year, :aggregate_type, :competition_ids, :team_points, :person_points, :options)

  def create_series_competitions(round, cups, assessments, points, type, options={})
    cups.each do |cup|
      assessments.each do |assessment|
        scores = send(:"series_#{type}_participations", cup.competition, assessment.gender, assessment.discipline, options)
        if options[:sorting].present?
          scores = scores.sort { |a, b| options[:sorting].call(a, b) }
        end
        create_participations(assessment, cup, scores, points)
      end
    end
  end

  def series_team_participations(competition, gender, discipline, options={})
    scores = competition.group_scores.gender(gender).discipline(discipline).best_of_competition(true)
    if options[:exclude_team_ids].present? && options[:exclude_team_ids][gender].present?
      scores = scores.where.not(team_id: options[:exclude_team_ids][gender])
    end
    if options[:exclude_group_score_ids].present?
      scores = scores.where.not(id: options[:exclude_group_score_ids])
    end
    scores.sort
  end

  def series_group_participations(competition, gender, discipline, options={})
    competition.group_assessment(discipline, gender)
  end

  def series_person_participations(competition, gender, discipline, options={})
    competition.scores.no_finals.gender(gender).discipline(discipline).best_of_competition.sort_by(&:time)
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
    sachsen_cup_point_sorting = -> (a, b) do
      compare = a <=> b
      return compare if compare != 0
      a.scores.count <=> b.scores.count
    end

    [
      RoundConfig.new("D-Cup", 2015, "DCup", [876, 754, 731], 10, 30, {}),

      # mv-hinderniscup: okay
      RoundConfig.new("MV-Hinderniscup", 2015, "MVHindernisCup", [728, 750, 820, 875], 0, 20, { only: [:hb] }),
      RoundConfig.new("MV-Hinderniscup", 2014, "MVHindernisCup", [460, 498, 575], 0, 20, { only: [:hb] }),
      RoundConfig.new("MV-Hinderniscup", 2013, "MVHindernisCup", [162, 201, 267, 258], 0, 20, { only: [:hb] }),

      # mv-steigercup: okay
      RoundConfig.new("MV-Steigercup", 2015, "MVSteigerCup", [728, 747, 820, 875], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2014, "MVSteigerCup", [460, 498, 555, 575], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2013, "MVSteigerCup", [162, 201, 258, 263], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2012, "MVSteigerCup", [48, 49, 50, 51], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2011, "MVSteigerCup", [32, 33, 34], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2010, "MVSteigerCup", [64, 65, 66], 0, 20, { only: [:hl] }),
      RoundConfig.new("MV-Steigercup", 2009, "MVSteigerCup", [22, 23, 24], 0, 20, { only: [:hl] }),

      # mv-cup 2015: okay
      RoundConfig.new("MV-Cup", 2015, "MVCup", [765, 745, 723, 700], 15, 0, {}),

      # mv-cup 2014: okay
      RoundConfig.new("MV-Cup", 2014, "MVCup", [419, 483, 491, 554], 15, 0, { exclude_team_ids: { female: [160, 586], male: [582, 579, 576, 1894] } }),
      
      # mv-cup 2013: okay
      RoundConfig.new("MV-Cup", 2013, "MVCup", [167, 181, 381, 382], 10, 0, { exclude_team_ids: { male: [579] } }),

      # mv-cup 2012: okay
      RoundConfig.new("MV-Cup", 2012, "MVCup", [109, 110, 107, 112], 10, 0, { exclude_team_ids: { female: [589, 586], male: [579, 582, 576, 587, 589] } }),

      # mv-cup 2011: okay
      RoundConfig.new("MV-Cup", 2011, "MVCup", [117, 118, 119, 108], 10, 0, { exclude_team_ids: { female: [159], male: [583, 510, 584, 589, 512, 585, 55, 581, 622, 582, 576] }, exclude_group_score_ids: GroupScore.where(team_id: 101, team_number: 1).pluck(:id) }),

      # mv-cup 2010: okay
      RoundConfig.new("MV-Cup", 2010, "MVCup", [113, 114, 115, 116], 10, 0, { exclude_team_ids: { female: [491, 624], male: [619, 624, 627, 41, 515, 622, 625, 626, 55, 582] }, exclude_group_score_ids: GroupScore.where(team_id: 101, team_number: 1).pluck(:id) }),

      # mv-cup 2009: okay
      RoundConfig.new("MV-Cup", 2009, "MVCup", [90, 94, 95, 98], 10, 0, { exclude_team_ids: { female: [2, 510, 499, 55, 512], male: [138, 458, 55, 515, 514, 513, 512, 510, 509, 498, 107] }, exclude_group_score_ids: GroupScore.where(team_id: 101, team_number: 1).pluck(:id)  }),
      RoundConfig.new("Sächsischer Steigercup", 2014, "SachsenSteigerCup", [389, 428, 710], 10, 30, { only: [:hl], sorting: sachsen_cup_point_sorting }),
    ]
  end

  def perform
    Series::Participation.delete_all
    Series::Assessment.delete_all
    Series::Cup.delete_all
    Series::Round.delete_all


    configs.each do |config|
      config.competition_ids = Competition.where(id: config.competition_ids).pluck(:id)
      config.options = config.options.with_indifferent_access
      round = Series::Round.create!(name: config.name, year: config.year, aggregate_type: config.aggregate_type)
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
            )
          end
        end
        create_series_competitions(round, cups, assessments, config.team_points, :team, config.options)
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
            )
          end
        end
        create_series_competitions(round, cups, assessments, config.team_points, :group)
      end
    end
  end
end