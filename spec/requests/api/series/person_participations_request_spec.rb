# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Series::PersonParticipations' do
  let(:participation) { create(:series_person_participation) }

  describe 'POST create' do
    let(:r) { -> { post '/api/series/person_participations', params: { series_person_participation: attributes } } }

    let(:cup) { create(:series_cup) }
    let(:assessment) { create(:series_person_assessment) }
    let(:person) { create(:person) }

    let(:attributes) do
      { cup_id: cup.id, person_assessment_id: assessment.id, person_id: person.id, time: '1234', rank: '22',
        points: '22' }
    end

    it 'creates new participation', login: :admin do
      expect do
        r.call
        expect_api_login_response(created_id: Series::PersonParticipation.last.id)
      end.to change(Series::PersonParticipation, :count).by(1)
      expect_change_log(after: { points: 22 }, log: 'create-series-personparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'GET show'  do
    let(:r) { -> { get "/api/series/person_participations/#{participation.id}" } }

    it 'returns participation', login: :admin do
      r.call
      expect_json_response
      expect(json_body[:series_person_participation]).to eq(
        person_assessment_id: participation.person_assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        person_id: participation.person_id,
        points: 15,
        rank: 2,
        second_time: '18,99',
        time: 1899,
      )
    end
  end

  describe 'GET index' do
    before { participation }

    it 'returns participations' do
      get '/api/series/person_participations'
      expect_json_response
      expect(json_body[:series_person_participations].first).to eq(
        person_assessment_id: participation.person_assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        person_id: participation.person_id,
        points: 15,
        rank: 2,
        second_time: '18,99',
        time: 1899,
      )
    end
  end

  describe 'PUT update' do
    let(:r) do
      -> {
        put "/api/series/person_participations/#{participation.id}", params: { series_person_participation: attributes }
      }
    end

    let(:attributes) { { person_id: create(:person).id, time: 1234, rank: 22, points: 22 } }

    it 'updates participation', login: :admin do
      r.call
      expect(json_body[:series_person_participation]).to include attributes
      expect_change_log(before: { points: 15 }, after: { points: 22 }, log: 'update-series-personparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'DELETE destroy' do
    let(:r) { -> { delete "/api/series/person_participations/#{participation.id}" } }

    before { participation }

    it 'destroys participation', login: :admin do
      expect do
        r.call
        expect_json_response
      end.to change(Series::PersonParticipation, :count).by(-1)
      expect_change_log(before: { points: 15 }, log: 'destroy-series-personparticipation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end
end
