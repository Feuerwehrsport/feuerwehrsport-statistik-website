# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::TeamCreationsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:team_attrs) { { name: 'FF Warin', shortcut: 'Warin', gender: :male } }

  describe 'GET new' do
    it 'redirects' do
      get :new, params: { competition_id: competition.id }
      expect(response).to be_successful
      expect(controller.parent_url).to eq registrations_competition_url(competition)
    end
  end

  describe 'POST create' do
    it 'saves' do
      expect do
        expect do
          post :create, params: { competition_id: competition.id, registrations_team: team_attrs }
          expect(response).to(
            redirect_to(edit_registrations_competition_team_path(competition, Registrations::Team.last)),
          )
        end.to change(Registrations::Team, :count).by(1)
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end
end
