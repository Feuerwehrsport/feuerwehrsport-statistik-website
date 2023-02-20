# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Series::ParticipationsController do
  let(:participation) { create(:series_person_participation) }

  describe 'POST create' do
    let(:r) { -> { post :create, params: { series_participation: attributes } } }

    let(:cup) { create(:series_cup) }
    let(:assessment) { create(:series_person_assessment) }
    let(:person) { create(:person) }

    let(:attributes) do
      { cup_id: cup.id, assessment_id: assessment.id, person_id: person.id, time: '1234', rank: '22', points: '22' }
    end

    it 'creates new participation', login: :admin do
      expect do
        r.call
        expect_api_login_response(created_id: Series::Participation.last.id)
      end.to change(Series::Participation, :count).by(1)
      expect_change_log(after: { points: 22 }, log: 'create-series-participation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'GET show' do
    let(:r) { -> { get :show, params: { id: participation.id } } }

    it 'returns participation', login: :admin do
      r.call
      expect_json_response
      expect(json_body[:series_participation]).to eq(
        assessment_id: participation.assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        participation_type: 'person',
        person_id: participation.person_id,
        points: 15,
        rank: 2,
        second_time: '18,99',
        team_id: nil,
        team_number: nil,
        time: 1899,
        type: 'Series::PersonParticipation',
      )
    end
  end

  describe 'GET index' do
    before { participation }

    it 'returns participations' do
      get :index
      expect_json_response
      expect(json_body[:series_participations].first).to eq(
        assessment_id: participation.assessment_id,
        cup_id: participation.cup_id,
        id: participation.id,
        participation_type: 'person',
        person_id: participation.person_id,
        points: 15,
        rank: 2,
        second_time: '18,99',
        team_id: nil,
        team_number: nil,
        time: 1899,
        type: 'Series::PersonParticipation',
      )
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put :update, params: { id: participation.id, series_participation: attributes } } }

    let(:attributes) { { person_id: create(:person).id, time: 1234, rank: 22, points: 22 } }

    it 'updates participation', login: :admin do
      r.call
      expect(json_body[:series_participation]).to include attributes
      expect_change_log(before: { points: 15 }, after: { points: 22 }, log: 'update-series-participation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'DELETE destroy' do
    let(:r) { -> { delete :destroy, params: { id: participation.id } } }

    before { participation }

    it 'destroys participation', login: :admin do
      expect do
        r.call
        expect_json_response
      end.to change(Series::Participation, :count).by(-1)
      expect_change_log(before: { points: 15 }, log: 'destroy-series-participation')
    end

    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end
end
