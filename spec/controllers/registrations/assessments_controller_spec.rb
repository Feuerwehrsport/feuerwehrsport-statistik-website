require 'rails_helper'

RSpec.describe Registrations::AssessmentsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition, admin_user: login_user) }
  let(:assessment) { create(:registrations_assessment, competition: competition) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'GET new' do
    it 'redirects' do
      get :new, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        post :create, competition_id: competition.id, registrations_assessment: { discipline: :hl, gender: :female }
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Assessment, :count).by(1)
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get :edit, competition_id: competition.id, id: assessment.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, competition_id: competition.id, id: assessment.id, registrations_assessment: { gender: :female }
      expect(response).to redirect_to(action: :index)
      expect(assessment.reload.gender).to eq 'female'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      assessment # to load instance
      expect do
        delete :destroy, competition_id: competition.id, id: assessment.id
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Assessment, :count).by(-1)
    end
  end
end
