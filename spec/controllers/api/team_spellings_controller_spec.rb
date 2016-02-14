require 'rails_helper'

RSpec.describe API::TeamSpellingsController, type: :controller do
  describe 'GET index' do
    it "returns team_spellings" do
      get :index
      expect_json_response
      expect(json_body[:team_spellings].first).to eq(team_id: 25, name: "Team Landkreis Leipzig", shortcut: "Landkreis Leipzig")
      expect(json_body[:team_spellings].count).to eq 29
    end
  end
end