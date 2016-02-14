require 'rails_helper'

RSpec.describe API::TeamMembersController, type: :controller do
  describe 'GET index' do
    it "returns team_members" do
      get :index
      expect_json_response
      expect(json_body[:team_members].first).to eq(person_id: 4, team_id: 3)
      expect(json_body[:team_members].count).to eq 159
    end
  end
end