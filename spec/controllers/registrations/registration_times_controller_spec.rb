require 'rails_helper'

RSpec.describe Registrations::RegistrationTimesController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET edit' do
    it 'renders form' do
      get :edit, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, competition_id: competition.id, registrations_competition: { open_at: '2018-01-01' }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(competition.reload.open_at).to eq Time.zone.parse('2018-01-01')
    end
  end
end
