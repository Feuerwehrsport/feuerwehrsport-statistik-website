require 'rails_helper'

RSpec.describe API::EventsController, type: :controller do
  describe 'POST create' do
    subject { -> { post :create, event: { name: "Wurstevent" } } }
    it "creates new event", login: :sub_admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Event, :count).by(1)
    end
    it_behaves_like "api user get permission error"
  end

  describe 'GET show' do
    it "returns event" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:event]).to eq(id: 1, name: "D-Cup")
    end
  end

  describe 'GET index' do
    it "returns events" do
      get :index
      expect_json_response
      expect(json_body[:events].first).to eq(id: 15, name: "Amtsausscheid")
    end
  end
end