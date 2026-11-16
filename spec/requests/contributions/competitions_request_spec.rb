# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::Competitions' do
  let!(:competition) { create(:competition) }
  let(:pdf) { fixture_file_upload('testfile.pdf', 'application/pdf') }

  describe 'change request', login: :api do
    let(:path) { "/contributions/competitions/#{competition.id}/change_request" }

    it 'creates a name proposal' do
      expect { post path, params: { kind: 'change-name', name: 'Neuer Name' } }.to change(ChangeRequest, :count).by(1)
      expect(ChangeRequest.last.content).to eq(
        key: 'competition-change-name', data: { competition_id: competition.id.to_s, name: 'Neuer Name' },
      )
    end

    it 'requires a hint' do
      expect { post path, params: { kind: 'add-hint', hint: ' ' } }.not_to change(ChangeRequest, :count)
      expect(response.body).to include('Bitte beschreibe deinen Hinweis.')
    end

    it 'only accepts files of the competition for file errors' do
      other_file = CompetitionFile.create!(competition: create(:competition, name: 'Anders'), file: pdf)
      post path, params: { kind: 'file-error', file_id: other_file.id, description: 'kaputt' }
      expect(response).to have_http_status(:not_found)
    end

    it 'shows admin links for file errors only to admins' do
      file = CompetitionFile.create!(competition:, file: pdf)
      get "#{path}/new", params: { kind: 'file-error', file_id: file.id }
      expect(response.body).to include('testfile.pdf')
      expect(response.body).not_to include("/backend/competition_files/#{file.id}")
    end
  end

  describe 'files', login: :api do
    let(:path) { "/contributions/competitions/#{competition.id}/files" }

    it 'uploads several files with their keys' do
      expect do
        rows = { '0' => { file: pdf, la_male: '1' }, '1' => { file: pdf, hl_female: '1' }, '2' => { hb_male: '1' } }
        post path, params: { competition_file: rows }
      end.to change(CompetitionFile, :count).by(2)
      expect(CompetitionFile.order(:id).map(&:keys)).to eq [%w[la_male], %w[hl_female]]
      expect(ChangeLog.last).to have_attributes(action: 'create-competitionfile', api_user: login_user)
      expect(response.body).to include('2 Dateien wurden gespeichert.')
    end

    it 'requires a file' do
      expect do
        post path, params: { competition_file: { '0' => { la_male: '1' } } }
      end.not_to change(CompetitionFile, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Bitte wähle mindestens eine Datei aus.')
    end

    it 'only accepts pdf files' do
      png = fixture_file_upload('testfile.png', 'image/png')
      expect do
        post path, params: { competition_file: { '0' => { file: png } } }
      end.not_to change(CompetitionFile, :count)
      expect(response.body).to include('Es dürfen nur PDF-Dateien hochgeladen werden.')
    end
  end

  context 'when admin', login: :admin do
    it 'shows backend links for file errors' do
      competition = create(:competition)
      file = CompetitionFile.create!(competition:, file: fixture_file_upload('testfile.pdf', 'application/pdf'))
      get "/contributions/competitions/#{competition.id}/change_request/new",
          params: { kind: 'file-error', file_id: file.id }
      expect(response.body).to include("/backend/competition_files/#{file.id}/edit")
    end
  end
end
