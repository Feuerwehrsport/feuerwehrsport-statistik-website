# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ImportRequests' do
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
  # same format as Feusport: Exports::FullDump#to_export_data
  let(:compressed_data) { Base64.encode64(Zlib::Deflate.deflate(export_hash.to_json)) }
  let(:params) { { import_request: { compressed_data: } } }
  let!(:admin_user) { create(:admin_user, :sub_admin) }

  before { allow(Rails.configuration.x).to receive(:feusport_import_tokens).and_return(%w[old-token secret-token]) }

  def expect_import_request_created(&)
    expect do
      expect(&).to change(ImportRequest, :count).by(1).and change(ImportRequestFile, :count).by(1)
    end.to have_enqueued_job(ApplicationMailer::DeliveryJob).exactly(:once)
  end

  describe 'POST create' do
    it 'creates new import_request with session login', login: :api do
      expect_import_request_created do
        post('/api/import_requests', params:)
        expect_api_login_response(created_id: ImportRequest.last.id)
      end
    end

    it 'creates new import_request with a valid token' do
      expect_import_request_created do
        post '/api/import_requests', params:, headers: { 'Authorization' => 'Bearer secret-token' }
        expect(response).to have_http_status(:ok)
        expect_api_not_login_response(created_id: ImportRequest.last.id)
      end
    end

    it 'accepts every configured token' do
      expect_import_request_created do
        post '/api/import_requests', params:, headers: { 'Authorization' => 'Bearer old-token' }
      end
    end

    it 'rejects an invalid token with 401' do
      expect do
        post '/api/import_requests', params:, headers: { 'Authorization' => 'Bearer wrong' }
      end.not_to change(ImportRequest, :count)
      expect(response).to have_http_status(:unauthorized)
      expect_json_response(success: false, message: 'Invalid token')
    end

    it 'rejects a token when none is configured' do
      allow(Rails.configuration.x).to receive(:feusport_import_tokens).and_return([])
      post '/api/import_requests', params:, headers: { 'Authorization' => 'Bearer secret-token' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an invalid token even with a session login', login: :api do
      post '/api/import_requests', params:, headers: { 'Authorization' => 'Bearer wrong' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not create without login or token' do
      expect do
        post('/api/import_requests', params:)
      end.not_to change(ImportRequest, :count)
      expect_api_not_login_response(success: false, message: 'You are not authorized to access this page.')
    end
  end
end
