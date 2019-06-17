require 'rails_helper'

RSpec.describe API::ImportRequestsController, type: :controller do
  let(:export_hash) do
    {
      files: [{
        name: 'test.to_json',
        mimetype: Mime[:json].to_s,
        base64_data: Base64.encode64('{"test":"data"}'),
      }],
      name: 'Wettkampf-Name',
      date: Date.current.to_s,
    }
  end
  let(:compressed_data) { Zlib::Deflate.deflate(export_hash.to_json) }
  let!(:admin_user) { create(:admin_user, :sub_admin) }

  describe 'POST create' do
    it 'creates new import_request', login: :api do
      expect do
        expect do
          expect do
            post :create, params: { import_request: { compressed_data: compressed_data } }
            expect_api_login_response(created_id: ImportRequest.last.id)
          end.to change(ImportRequest, :count).by(1)
        end.to change(ImportRequestFile, :count).by(1)
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
