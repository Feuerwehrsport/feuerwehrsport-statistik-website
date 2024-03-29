# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Publishings', login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/publishings/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/competitions/#{competition.id}/publishings",
            params: { registrations_competition: { slug: 'warin' } }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(competition.reload.slug).to eq 'warin'
    end
  end
end
