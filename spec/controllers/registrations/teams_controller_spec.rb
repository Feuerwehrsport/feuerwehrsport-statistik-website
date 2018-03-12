require 'rails_helper'

RSpec.describe Registrations::TeamsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:team) { create(:registrations_team, competition: competition) }

  describe 'GET new' do
    it 'redirects' do
      get :new, competition_id: competition.id
      expect(response).to redirect_to(action: :new_select_gender)
    end
  end

  describe 'GET new_select_gender' do
    it 'renders gender select' do
      get :new_select_gender, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'POST create' do
    context 'when gender selected' do
      it 'renders new' do
        expect_any_instance_of(Registrations::Team).not_to receive(:save)
        post :create, competition_id: competition.id, from_gender_select: true, registrations_team: { gender: :male }
        expect(response).to be_success
      end
    end

    context 'when real save' do
      it 'saves' do
        expect do
          expect_any_instance_of(Registrations::Team).to receive(:save).and_call_original
          post :create, competition_id: competition.id,
                        registrations_team: { gender: :male, name: 'Warin', shortcut: 'Warin' }
          expect(response).to redirect_to(action: :show, id: Registrations::Team.last.id)
        end.to change(Registrations::Team, :count).by(1)
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get :edit, id: team.id, competition_id: competition.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, id: team.id, competition_id: competition.id, registrations_team: { name: 'new-name' }
      expect(response).to redirect_to(action: :show)
      expect(team.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      team # to load instance
      expect do
        delete :destroy, id: team.id, competition_id: competition.id
        expect(response).to redirect_to(registrations_competition_path(competition))
      end.to change(Registrations::Team, :count).by(-1)
    end
  end
end
