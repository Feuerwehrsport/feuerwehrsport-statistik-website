# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ChangeRequests' do
  let(:files_data) { {} }
  let!(:change_request) do
    ChangeRequest.create!(content: { key: 'person-nation-changed', data: { person_id: 1 } }, files_data:)
  end

  describe 'POST create' do
    let(:r) { -> { post '/api/change_requests', params: { change_request: { content: { foo: { bar: '1' } } } } } }

    it 'creates new change request', login: :api do
      expect do
        r.call
        expect_api_login_response(created_id: ChangeRequest.last.id)
      end.to change(ChangeRequest, :count).by(1)
      expect(ChangeRequest.last.content).to eq foo: { bar: '1' }
      expect_change_log(after: { done_at: nil }, log: 'create-changerequest')
    end

    it 'sends notification', login: :api do
      create(:admin_user, :admin)
      expect do
        r.call
        expect_api_login_response(created_id: ChangeRequest.last.id)
      end.to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  describe 'GET index' do
    let(:r) { -> { get '/api/change_requests' } }

    it 'returns change_requests', login: :sub_admin do
      r.call
      expect_json_response
      expect(json_body[:change_requests].count).to eq 1
      expect(json_body[:change_requests].first).to include(
        content: { key: 'person-nation-changed', data: { person_id: 1 } },
        done_at: nil,
        files: [],
      )
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET files' do
    let(:r) { -> { get "/api/change_requests/#{change_request.id}/files/0" } }

    let(:files_data) do
      {
        files: [
          binary: Base64.encode64('content'),
          filename: 'content.txt',
          content_type: 'text/plain',
        ],
      }
    end

    it 'returns change_request file', login: :sub_admin do
      r.call
      expect_json_response
      expect(json_body[:change_request_file]).to eq(
        binary: "Y29udGVudA==\n",
        content_type: 'text/plain',
        filename: 'content.txt',
      )
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'PUT update' do
    let(:r) { -> { put "/api/change_requests/#{change_request.id}", params: { change_request: { done: '1' } } } }

    it 'update change_request', login: :sub_admin do
      r.call
      expect_json_response
      expect(change_request.reload.done_at).not_to be_nil
      expect_change_log(before: { done_at: nil }, after: {}, log: 'update-changerequest')
    end

    it_behaves_like 'api user get permission error'
  end
end
