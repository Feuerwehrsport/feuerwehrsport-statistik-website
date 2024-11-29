# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Scores' do
  let(:score) { create(:score, :double) }
  let(:correct_score) do
    {
      id: score.id,
      team_id: score.team_id,
      team_number: 1,
      time: 1976,
      discipline_key: 'hb',
      single_discipline_id: 3,
      second_time: '19,76',
      translated_discipline_name: 'Hindernisbahn',
      person: 'Alfred Meier',
      similar_scores: [
        {
          id: score.id,
          time: 1976,
          second_time: '19,76',
          discipline_key: 'hb',
          translated_discipline_name: 'Hindernisbahn',
          team_id: score.team_id,
          team_number: 1,
        }, {
          id: (score.person.score_ids - [score.id]).first,
          time: 2091,
          second_time: '20,91',
          discipline_key: 'hb',
          translated_discipline_name: 'Hindernisbahn',
          team_id: score.team_id,
          team_number: 1,
        }
      ],
    }
  end

  describe 'GET show' do
    it 'returns score' do
      get "/api/scores/#{score.id}"
      expect_json_response
      expect(json_body[:score]).to eq(correct_score)
    end
  end

  describe 'GET index' do
    before { score }

    it 'returns scores' do
      get '/api/scores'
      expect_json_response
      expect(json_body[:scores].first).to eq(correct_score)
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put  "/api/scores/#{score.id}", params: { score: { team_id: mv.id, team_number: '-2' } } } }

    let(:mv) { create(:team, :mv) }

    it 'update score', login: :api do
      r.call
      expect_json_response
      expect(json_body[:score]).to include(team_id: mv.id, team_number: -2)
      expect(Score.find(score.id).team_id).to eq mv.id
      expect_change_log(before: { team_id: score.team_id }, after: { team_id: mv.id }, log: 'update-score')
    end
  end
end
