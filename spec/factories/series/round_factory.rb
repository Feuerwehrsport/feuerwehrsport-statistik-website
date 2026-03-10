# frozen_string_literal: true

FactoryBot.define do
  factory :series_round, class: 'Series::Round' do
    kind { Series::Kind.first || build(:series_kind) }
    year { 2016 }
    team_assessments_config_jsonb do
      [
        {
          key: 'female',
          disciplines: ['la'],
          name: 'Frauen',
          calc_participations_count: 3,
          min_participations_count: 2,
          points_for_rank:
            [
              15,
              14,
              13,
            ],
          ranking_logic:
            %w[
              participation_count
              points
              sum_time
              best_time
            ],
        },
        {
          key: 'male',
          disciplines: ['la'],
          name: 'Männer',
          calc_participations_count: 1,
          min_participations_count: 1,
          ranking_logic: %w[points],
          honor_ranking_logic:
            %w[
              points
              best_rank
            ],
        },
      ]
    end
    person_assessments_config_jsonb do
      [
        {
          key: 'female',
          disciplines: ['hb'],
          name: 'Frauen',
          calc_participations_count: 2,
          min_participations_count: 2,
          points_for_rank: [1],
          ranking_logic: %w[best_time],
        },
      ]
    end
  end
end
