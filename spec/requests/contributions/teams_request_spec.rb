# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::Teams', login: :api do
  let!(:team) { create(:team) }

  describe 'team' do
    it 'creates a team' do
      expect do
        post '/contributions/teams', params: { team: { name: 'FF Neu', shortcut: 'Neu', status: 'fire_station' } }
      end.to change(Team, :count).by(1)
      expect(response.body).to include('FF Neu wurde angelegt')
      expect(ChangeLog.last).to have_attributes(action: 'create-team', api_user: login_user)
    end

    it 'shows errors' do
      expect { post '/contributions/teams', params: { team: { name: '' } } }.not_to change(Team, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'state' do
    let(:path) { "/contributions/teams/#{team.id}/state" }

    it 'updates the state with change log' do
      patch path, params: { state: 'BB' }
      expect(team.reload.state).to eq 'BB'
      expect(ChangeLog.last).to have_attributes(action: 'update-team:state', api_user: login_user)
      expect(ChangeLog.last.content[:before_hash]).to include(state: 'MV')
      expect(ChangeLog.last.content[:after_hash]).to include(state: 'BB')
    end

    it 'allows unknown state' do
      patch path, params: { state: '' }
      expect(team.reload.state).to be_nil
    end

    it 'rejects states not in the list' do
      patch path, params: { state: 'XX' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(team.reload.state).to eq 'MV'
    end
  end

  describe 'change request' do
    let!(:other_team) { create(:team, name: 'FF Anders', shortcut: 'Anders') }
    let(:path) { "/contributions/teams/#{team.id}/change_request" }

    it 'searches teams for merge without the team itself' do
      get "#{path}/new", params: { kind: 'merge', q: 'Anders' }
      expect(response.body).to include('FF Anders (Anders)')
      expect(response.body).not_to include("value=\"#{team.id}\"")
    end

    it 'creates a merge request with mail' do
      expect do
        post path, params: { kind: 'merge', correct_team_id: other_team.id }
      end.to change(ChangeRequest, :count).by(1).and have_enqueued_mail(ChangeRequestMailer, :new_notification)
      expect(ChangeRequest.last.content).to eq(
        key: 'team-merge', data: { team_id: team.id.to_s, correct_team_id: other_team.id.to_s },
      )
    end

    it 'does not merge a team with itself' do
      expect { post path, params: { kind: 'merge', correct_team_id: team.id } }.not_to change(ChangeRequest, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'rejects an invalid status for correction and keeps the input' do
      post path, params: { kind: 'correction', team: { name: 'FF Neu', shortcut: 'Neu', status: 'club' } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Bitte wähle einen gültigen Typ.', 'value="FF Neu"')
    end

    it 'accepts a logo image' do
      logo = fixture_file_upload('testfile.pdf', 'application/pdf')
      expect { post path, params: { kind: 'logo', logo: } }.to change(ChangeRequest, :count).by(1)
      expect(ChangeRequest.last.files.first.filename).to eq 'testfile.pdf'
    end

    it 'rejects other files as logo' do
      logo = fixture_file_upload('testfile.pdf', 'text/plain')
      expect { post path, params: { kind: 'logo', logo: } }.not_to change(ChangeRequest, :count)
      expect(response.body).to include('Bitte wähle ein Bild oder eine PDF-Datei aus.')
    end
  end
end
