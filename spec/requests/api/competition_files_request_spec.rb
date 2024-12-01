# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::CompetitionFiles' do
  let(:competition) { create(:competition, :score_type, :fake_count) }
  let(:other_competition) { create(:competition) }
  let(:competition_file) { create(:competition_file, competition:) }

  describe 'POST files' do
    let(:testfile) { fixture_file_upload('testfile.pdf', 'application/pdf') }

    it 'creates files', login: :api do
      expect do
        post "/api/competitions/#{competition.id}/competition_files", params: {
          competition_file: { '0' => { file: testfile, hl_male: '1', hb_female: '1' } },
        }
      end.to change(CompetitionFile, :count).by(1)
      expect(response).to redirect_to competition_path(competition.id, anchor: 'toc-dateien')
      expect(CompetitionFile.last.keys).to match_array %w[hl_male hb_female]
      expect(CompetitionFile.last.competition_id).to eq competition.id
      expect_change_log(after: { competition_id: competition.id }, log: 'create-competitionfile')
    end
  end

  describe 'PUT update' do
    let(:r) do
      -> {
        put "/api/competitions/#{competition.id}/competition_files/#{competition_file.id}",
            params: { competition_file: { competition_id: other_competition.id } }
      }
    end

    it 'update competition file', login: :sub_admin do
      r.call
      expect_json_response
      expect(json_body[:competition_file]).to eq(
        id: competition_file.id,
        competition_id: other_competition.id,
      )
      expect_change_log(
        before: { id: competition_file.id, competition_id: competition.id },
        after: { id: competition_file.id, competition_id: other_competition.id },
        log: 'update-competitionfile',
      )
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'DELETE destroy' do
    let(:r) { -> { delete "/api/competitions/#{competition.id}/competition_files/#{competition_file.id}" } }

    before { competition_file }

    it 'destroys file', login: :sub_admin do
      expect do
        r.call
        expect_json_response
      end.to change(CompetitionFile, :count).by(-1)
      expect_change_log(before: {}, log: 'destroy-competitionfile')
    end

    it_behaves_like 'api user get permission error'
  end
end
