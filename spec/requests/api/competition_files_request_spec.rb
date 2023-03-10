# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::CompetitionFiles' do
  let(:competition) { create(:competition, :score_type, :fake_count) }

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
end
