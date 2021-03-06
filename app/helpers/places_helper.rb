module PlacesHelper
  def disciplines_overview
    competition_ids = @competitions.map(&:id)
    [
      DisciplineScoreOverview.new(:hb, :female, competition_ids),
      DisciplineScoreOverview.new(:hb, :male, competition_ids),
      DisciplineScoreOverview.new(:hl, :female, competition_ids),
      DisciplineScoreOverview.new(:hl, :male, competition_ids),
      DisciplineScoreOverview.new(:gs, :female, competition_ids),
      DisciplineScoreOverview.new(:la, :female, competition_ids),
      DisciplineScoreOverview.new(:la, :male, competition_ids),
      DisciplineScoreOverview.new(:fs, :female, competition_ids),
      DisciplineScoreOverview.new(:fs, :male, competition_ids),
    ]
  end

  DisciplineScoreOverview = Struct.new(:discipline, :gender, :competition_ids) do
    def get
      if Discipline.group?(discipline)
        group_score_types = GroupScoreType.where(discipline: discipline_config[:discipline]).map do |group_score_type|
          scores = GroupScore .joins(:group_score_category) .where(group_score_categories:
            { competition_id: competition_ids, group_score_type_id: group_score_type.id })
          OpenStruct.new(type: group_score_type, calculation: calculation(scores))
        end
        group_score_types.reject { |c| c.calculation.count.zero? }
      else
        scores = Score.where(competition: competition_ids).german.discipline(discipline)
        [OpenStruct.new(type: nil, calculation: calculation(scores))]
      end
    end

    def calculation(scores)
      years = Year.all.map do |year|
        OpenStruct.new(
          year: year,
          best: scores.year(year).valid.order(:time).limit(1),
        )
      end
      OpenStruct.new(
        count: scores.count,
        average: scores.valid.average(:time),
        best: scores.valid.order(:time).limit(1),
        years: years.reject { |y| y.best.nil? },
      )
    end
  end
end
