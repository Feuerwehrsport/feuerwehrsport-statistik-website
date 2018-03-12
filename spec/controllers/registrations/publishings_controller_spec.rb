require 'rails_helper'

RSpec.describe Registrations::PublishingsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET edit' do
    it 'renders form' do
      get :edit, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, competition_id: competition.id, registrations_competition: { slug: 'warin' }
      expect(response).to redirect_to(registrations_competition_path(competition))
      expect(competition.reload.slug).to eq 'warin'
    end
  end
end
