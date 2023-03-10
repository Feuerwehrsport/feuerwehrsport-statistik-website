# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Assessments', login: :user do
  let(:competition) { create(:registrations_competition, admin_user: login_user) }
  let(:assessment) { create(:registrations_assessment, competition:) }

  describe 'GET index' do
    it 'assigns collection' do
      get "/registrations/competitions/#{competition.id}/assessments"
      expect(response).to be_successful
    end
  end

  describe 'GET new' do
    it 'redirects' do
      get "/registrations/competitions/#{competition.id}/assessments/new"
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        post "/registrations/competitions/#{competition.id}/assessments", params: {
          registrations_assessment: { discipline: :hl, gender: :female },
        }
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Assessment, :count).by(1)
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/assessments/#{assessment.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/competitions/#{competition.id}/assessments/#{assessment.id}", params: {
        registrations_assessment: { gender: :female },
      }
      expect(response).to redirect_to(action: :index)
      expect(assessment.reload.gender).to eq 'female'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      assessment # to load instance
      expect do
        delete "/registrations/competitions/#{competition.id}/assessments/#{assessment.id}"
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Assessment, :count).by(-1)
    end
  end
end
