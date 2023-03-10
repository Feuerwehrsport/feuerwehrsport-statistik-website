# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Tags', login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/tags/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/competitions/#{competition.id}/tags",
            params: { registrations_competition: { person_tags: 'U20' } }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(competition.reload.person_tags).to eq 'U20'
    end
  end
end
