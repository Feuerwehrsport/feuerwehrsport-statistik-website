require 'rails_helper'

RSpec.describe API::UsersController, type: :controller do
  describe 'GET status' do
    context "when session is not set" do
      it "returns login false" do
        get :status
        expect_json_response
        expect(json_body).to eq(success: true, login: false)
      end
    end

    context "when session user id is set" do
      it "returns login false" do
        expect(User).to receive(:find).with(99).and_return(:user)
        get :status, {}, { user_id: 99 }
        expect_json_response
        expect(json_body).to eq(success: true, login: true)
      end
    end
  end
end