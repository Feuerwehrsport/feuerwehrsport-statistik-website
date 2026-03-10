# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::Rounds' do
  let(:round) { create(:series_round) }

  describe 'GET show' do
    it 'returns round' do
      get "/api/series/rounds/#{round.id}"
      expect_json_response
      expect(json_body[:series_round]).to eq(
        id: round.id,
        name: 'D-Cup',
        year: 2016,
        full_cup_count: 4,
        official: false,
        person_assessments_configs: [
          {
            key: 'female',
            name: 'Frauen',
            disciplines: ['hb'],
            calc_participations_count: 2,
            min_participations_count: 2,
            points_for_rank: [1],
            ranking_logic: ['best_time'],
          },
        ],
        team_assessments_configs: [
          {
            key: 'female',
            name: 'Frauen',
            disciplines: ['la'],
            calc_participations_count: 3,
            min_participations_count: 2,
            points_for_rank: [15, 14, 13],
            ranking_logic: %w[participation_count points sum_time best_time],
          }, {
            key: 'male',
            name: 'Männer',
            disciplines: ['la'],
            calc_participations_count: 1,
            min_participations_count: 1,
            ranking_logic: ['points'],
            honor_ranking_logic: %w[points best_rank],
          }
        ],
      )
    end
  end

  describe 'GET index' do
    before { round }

    it 'returns rounds' do
      get '/api/series/rounds'
      expect_json_response
      expect(json_body[:series_rounds].first).to eq(
        id: round.id,
        name: 'D-Cup',
        year: 2016,
        full_cup_count: 4,
        official: false,
        person_assessments_configs: [
          {
            key: 'female',
            name: 'Frauen',
            disciplines: ['hb'],
            calc_participations_count: 2,
            min_participations_count: 2,
            points_for_rank: [1],
            ranking_logic: ['best_time'],
          },
        ],
        team_assessments_configs: [
          {
            key: 'female',
            name: 'Frauen',
            disciplines: ['la'],
            calc_participations_count: 3,
            min_participations_count: 2,
            points_for_rank: [15, 14, 13],
            ranking_logic: %w[participation_count points sum_time best_time],
          }, {
            key: 'male',
            name: 'Männer',
            disciplines: ['la'],
            calc_participations_count: 1,
            min_participations_count: 1,
            ranking_logic: ['points'],
            honor_ranking_logic: %w[points best_rank],
          }
        ],
      )
    end
  end
end
