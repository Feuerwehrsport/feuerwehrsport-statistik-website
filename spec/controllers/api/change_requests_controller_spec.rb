require 'rails_helper'

RSpec.describe API::ChangeRequestsController, type: :controller do
  describe 'POST create' do
    it "creates new change request", login: :api do
      expect {
        post :create, change_request: { content: { foo: { bar: "1" } } }
        expect_api_response
      }.to change(ChangeRequest, :count).by(1)
      expect(ChangeRequest.last.content).to eq foo: { bar: "1" }
    end
  end
end