require 'rails_helper'

RSpec.describe API::Series::ParticipationsController, type: :controller do
  let(:participation) { create(:series_person_participation) }

  describe 'POST create' do
    let(:cup) { create(:series_cup) }
    let(:assessment) { create(:series_person_assessment) }
    let(:person) { create(:person) }

    let(:attributes) { { cup_id: cup.id, assessment_id: assessment.id, person_id: person.id, time: '1234', rank: '22', points: '22' } }
    subject { -> { post :create, series_participation: attributes } }
    it 'creates new participation', login: :admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Series::Participation, :count).by(1)
    end
    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'GET show' do
    subject { -> { get :show, id: participation.id } }
    it 'returns participation', login: :admin do
      subject.call
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
    it "returns participations" do
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
    let(:attributes) { { person_id: create(:person).id, time: 1234, rank: 22, points: 22 } }
    subject { -> { put :update, id: participation.id, series_participation: attributes } }
    it 'updates participation', login: :admin do
      subject.call
      expect(json_body[:series_participation]).to include attributes
    end
    it_behaves_like 'api user get permission error'
    it_behaves_like 'sub_admin get permission error'
  end

  describe 'DELETE destroy' do
    before { participation }
    subject { -> { delete :destroy, id: participation.id } }
    it 'destroys participation', login: :admin do
      expect {
        subject.call
        expect_json_response
      }.to change(Series::Participation, :count).by(-1)
    end
    it_behaves_like 'api user get permission error'
    it_behaves_like "sub_admin get permission error"
  end
end