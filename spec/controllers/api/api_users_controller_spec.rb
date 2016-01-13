require 'rails_helper'

RSpec.describe API::APIUsersController, type: :controller do
  describe 'GET status' do
    context "when session is not set" do
      it "returns login false" do
        get :status
        expect_api_response login: false
      end
    end

    context "when session user id is set" do
      it "returns login false" do
        expect(APIUser).to receive(:find_by_id).with(99).and_return(:user)
        get :status, {}, { user_id: 99 }
        expect_api_response
      end
    end
  end

  describe 'POST create' do
    it "creates new user and sign in" do
      expect {
        post :create, api_user: { name: "Benutzer", email_address: "email-address@foo.de" }
      }.to change(APIUser, :count).by(1)
      expect_api_response
    end

    context "when email_address is not valid" do
      it "fails to create new user" do
        post :create, api_user: { name: "Benutzer", email_address: "not-valid" }
        expect_api_response success: false, login: false, message: "E-Mail-Adresse ist offensichtlich keine gültige E-Mail-Adresse"
      end
    end
  end
end