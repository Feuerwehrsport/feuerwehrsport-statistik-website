# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Assessments', login: :user do
  let(:competition) { create(:registrations_competition, admin_user: login_user) }
  let(:band) { create(:registrations_band, competition:) }
  let(:assessment) { create(:registrations_assessment, band:) }

  describe 'GET new' do
    it 'redirects' do
      get "/registrations/bands/#{band.id}/assessments/new"
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        post "/registrations/bands/#{band.id}/assessments", params: {
          registrations_assessment: { name: 'foo', discipline: :hl },
        }
        expect(response).to redirect_to(registrations_competition_bands_path(competition))
      end.to change(Registrations::Assessment, :count).by(1)
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/bands/#{band.id}/assessments/#{assessment.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/bands/#{band.id}/assessments/#{assessment.id}", params: {
        registrations_assessment: { name: 'foo' },
      }
      expect(response).to redirect_to(registrations_competition_bands_path(competition))
      expect(assessment.reload.name).to eq 'foo'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      assessment # to load instance
      expect do
        delete "/registrations/bands/#{band.id}/assessments/#{assessment.id}"
        expect(response).to redirect_to(registrations_competition_bands_path(competition))
      end.to change(Registrations::Assessment, :count).by(-1)
    end
  end
end
