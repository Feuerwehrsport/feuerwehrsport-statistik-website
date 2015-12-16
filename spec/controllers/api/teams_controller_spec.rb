require 'rails_helper'

RSpec.describe API::TeamsController, type: :controller do
  describe 'POST create' do
    it "creates new team", login: :api do
      expect {
        post :create, team: { name: "Mannschaft1", shortcut: "Mann1", status: "fire_station" }
        expect_api_response
      }.to change(Team, :count).by(1)
    end
  end
end