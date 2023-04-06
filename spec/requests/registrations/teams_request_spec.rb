# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Teams', login: :user do
  let(:competition) { create(:registrations_competition) }
  let(:band) { create(:registrations_band, competition:) }
  let(:team) { create(:registrations_team, band:) }

  describe 'GET show' do
    before { Timecop.freeze(Date.parse('2018-03-21')) }

    after { Timecop.return }

    it 'assigns resource' do
      get "/registrations/bands/#{band.id}/teams/#{team.id}"
      expect(controller.send(:resource)).to be_a Registrations::Team
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get "/registrations/bands/#{band.id}/teams/#{team.id}.pdf"
        expect(controller.send(:resource)).to be_a Registrations::Team
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq(
          "inline; filename=\"ff-mannschaft.pdf\"; filename*=UTF-8''ff-mannschaft.pdf",
        )
      end
    end

    context 'when xlsx requested' do
      it 'sends xlsx' do
        get "/registrations/bands/#{band.id}/teams/#{team.id}.xlsx"
        expect(controller.send(:resource)).to be_a Registrations::Team
        expect(response).to be_successful
        expect(response.content_type).to eq(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8',
        )
        expect(response.headers['Content-Disposition']).to eq('attachment; filename="ff-mannschaft.xlsx"')
        expect(response.body.length).to be > 4000
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/bands/#{band.id}/teams/#{team.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    let!(:assessment) { create(:registrations_assessment, :la, band:) }

    it 'updates' do
      patch "/registrations/bands/#{band.id}/teams/#{team.id}",
            params: { registrations_team: { name: 'new-name' } }
      expect(response).to redirect_to(action: :show)
      expect(team.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      team # to load instance
      expect do
        delete "/registrations/bands/#{band.id}/teams/#{team.id}"
        expect(response).to redirect_to(registrations_competition_path(competition))
      end.to change(Registrations::Team, :count).by(-1)
    end
  end
end
