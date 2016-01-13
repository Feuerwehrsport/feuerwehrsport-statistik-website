require 'rails_helper'

RSpec.describe API::ChangeRequestsController, type: :controller do
  let(:files_data) { {} }
  let!(:change_request) { ChangeRequest.create!(content: { key: "person-nation-changed", data: { person_id: 1 }}, files_data: files_data) }
  describe 'POST create' do
    it "creates new change request", login: :api do
      expect {
        post :create, change_request: { content: { foo: { bar: "1" } } }
        expect_api_login_response
      }.to change(ChangeRequest, :count).by(1)
      expect(ChangeRequest.last.content).to eq foo: { bar: "1" }
    end
  end

  describe 'GET index' do
    it "returns change_requests" do
      get :index
      expect_json_response
      expect(json_body[:change_requests].count).to eq 1
      expect(json_body[:change_requests].first).to include(
        content: { key: "person-nation-changed", data: { person_id: 1 }},
        done_at: nil,
        files: [],
        id: 3,
      )
    end
  end

  describe 'GET files' do
    let(:files_data) do
      { 
        files: [
          binary: Base64.encode64("content"),
          filename: "content.txt",
          content_type: "text/plain",
        ]
      }
    end
    it "returns change_request file" do
      get :files, change_request_id: change_request.id, id: 0
      expect_json_response
      expect(json_body[:change_request_file]).to eq(
        binary: "Y29udGVudA==\n",
        content_type: "text/plain",
        filename: "content.txt",
      )
    end
  end

  describe 'PUT update' do
    it "update change_request", login: :api do
      put :update, id: change_request.id, change_request: { done: "1" }
      expect_json_response
      expect(change_request.reload.done_at).to_not be nil
    end
  end
end