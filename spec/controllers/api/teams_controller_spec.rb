require 'rails_helper'

RSpec.describe API::TeamsController, type: :controller do
  describe 'POST create' do
    subject { -> { post :create, team: { name: "Mannschaft1", shortcut: "Mann1", status: "fire_station" } } }
    it "creates new team", login: :api do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Team, :count).by(1)
    end
  end

  describe 'GET show' do
    it "returns team" do
      get :show, id: 1
      expect(json_body[:team]).to eq(
        id: 1,
        latitude: "52.5611297253",
        longitude: "14.0714263916",
        name: "FF Buckow",
        shortcut: "Buckow",
        state: "BB",
        status: "fire_station",
        tile_path: nil,
      )
    end

    context "when extended" do
      it "returns team" do
        get :show, id: 1, extended: "1"
        expect(json_body[:team]).to include(
          id: 1,
          latitude: "52.5611297253",
          longitude: "14.0714263916",
          name: "FF Buckow",
          shortcut: "Buckow",
          state: "BB",
          status: "fire_station",
          tile_path: nil,
        )
        expect(json_body[:team][:single_scores]).to have(59).items
        expect(json_body[:team][:la_scores]).to have(5).items
        expect(json_body[:team][:fs_scores]).to have(0).items
        expect(json_body[:team][:gs_scores]).to have(0).items
      end
    end
  end

  describe 'GET index' do
    it "returns teams" do
      get :index
      expect_json_response
      expect(json_body[:teams].first).to include(id: 7, name: "Auswahl Berlin")
    end
  end

  describe 'PUT update' do
    let(:team_attributes) { { latitude: "12", longitude: "34" } }
    subject { -> { put :update, id: 1, team: team_attributes } }
    it "updates team", login: :api do
      subject.call
      expect(json_body[:team]).to eq(
        id: 1,
        latitude: "12.0",
        longitude: "34.0",
        name: "FF Buckow",
        shortcut: "Buckow",
        state: "BB",
        status: "fire_station",
        tile_path: nil,
      )
    end

    context "when updating extended attributes" do
      let(:team_attributes) { { name: "FF Hanswurst", shortcut: "Hanswurst", status: "team" } }
      context "when user have not enough permissions", login: :api do
        it "failes to update" do
          subject.call
          expect(json_body[:team]).to include(
            name: "FF Buckow",
            shortcut: "Buckow",
            status: "fire_station",
          )
        end
      end
      it "success", login: :sub_admin do
        subject.call
        expect(json_body[:team]).to include(team_attributes)
      end
    end
  end

  describe 'POST merge' do
    subject { -> { put :merge, id: 1, correct_team_id: 2, always: 1 } }
    it "merge two teams", login: :sub_admin do
      expect_any_instance_of(Team).to receive(:merge_to).and_call_original
      expect {
        subject.call
      }.to change(TeamSpelling, :count).by(1)
      
      expect_json_response
      expect(json_body[:team]).to eq(
        id: 2,
        latitude: "53.6851567563",
        longitude: "12.2669005394",
        name: "Team Mecklenburg-Vorpommern",
        shortcut: "Team MV",
        state: "MV",
        status: "team",
        tile_path: nil,
      )
    end
    it_behaves_like "api user get permission error"
  end
end