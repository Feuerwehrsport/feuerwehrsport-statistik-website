# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::RegistrationTimes', login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/registration_times/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/competitions/#{competition.id}/registration_times",
            params: { registrations_competition: { open_at: '2018-01-01' } }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(competition.reload.open_at).to eq Time.zone.parse('2018-01-01')
    end
  end
end
