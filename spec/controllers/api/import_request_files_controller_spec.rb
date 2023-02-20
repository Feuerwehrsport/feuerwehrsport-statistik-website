# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::ImportRequestFilesController, type: :controller do
  let(:import_request) { create(:import_request) }
  let(:file) { import_request.import_request_files.first }
  let(:competition) { create(:competition) }

  describe 'PATCH update' do
    it 'creates new import_request', login: :sub_admin do
      expect do
        patch :update, params: {
          id: file.id,
          import_request_file: { transfer_competition_id: competition.id, transfer_keys_string: 'hl_female,hb_female' },
        }
        expect_api_login_response(
          resource_name: 'import_request_file',
          import_request_file: { file: { url: "/uploads/import_request_file/file/#{file.id}/testfile.pdf" },
                                 id: file.id },
        )
      end.to change(CompetitionFile, :count).by(1)
      expect(CompetitionFile.last.keys_string).to eq 'hl_female,hb_female'
    end
  end
end
