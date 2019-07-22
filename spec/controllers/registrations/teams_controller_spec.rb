require 'rails_helper'

RSpec.describe Registrations::TeamsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition, team_tags: 'Sport') }
  let(:team) { create(:registrations_team, competition: competition) }

  describe 'GET show' do
    before { Timecop.freeze(Date.parse('2018-03-21')) }

    after { Timecop.return }

    it 'assigns resource' do
      get :show, params: { id: team.id, competition_id: competition.id }
      expect(controller.send(:resource)).to be_a Registrations::Team
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get :show, params: { id: team.id, competition_id: competition.id, format: :pdf }
        expect(controller.send(:resource)).to be_a Registrations::Team
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq('inline; filename="ff-mannschaft.pdf"')
      end
    end

    context 'when xlsx requested' do
      render_views
      it 'sends xlsx' do
        get :show, params: { id: team.id, competition_id: competition.id, format: :xlsx }
        expect(controller.send(:resource)).to be_a Registrations::Team
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        expect(response.headers['Content-Disposition']).to eq('attachment; filename="ff-mannschaft.xlsx"')
        expect(response.body.length).to eq 4514
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get :edit, params: { id: team.id, competition_id: competition.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    let!(:assessment) { create(:registrations_assessment, :la, competition: competition) }

    it 'updates' do
      patch :update, params: { id: team.id, competition_id: competition.id, registrations_team: { name: 'new-name' } }
      expect(response).to redirect_to(action: :show)
      expect(team.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      team # to load instance
      expect do
        delete :destroy, params: { id: team.id, competition_id: competition.id }
        expect(response).to redirect_to(registrations_competition_path(competition))
      end.to change(Registrations::Team, :count).by(-1)
    end
  end
end
