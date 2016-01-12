require 'rails_helper'

RSpec.describe API::ImportsController, type: :controller do
  describe 'POST check_lines', login: :api do
    let(:raw_lines) { "Warin;foo;22\nFF Wurststadt;bla;44\nFC Hansa Rostock;blub;D" }
    it "returns group_score" do
      post :check_lines, import: { discipline: "la", gender: "male", separator: ";", raw_headline_columns: "team;col;time", raw_lines: raw_lines }
      expect_api_response(
        missing_teams: ["FF Wurststadt", "FC Hansa Rostock"],
        import_lines: [
          {
            valid: true, 
            last_name: "", 
            first_name: "", 
            times: [2200], 
            team_names: ["Warin"], 
            original_team: "Warin", 
            run: "A", 
            team_number: 1, 
            team_ids: [59], 
            people: []
          }, {
            valid: true, 
            last_name: "", 
            first_name: "", 
            times: [4400], 
            team_names: [], 
            original_team: "FF Wurststadt", 
            run: "A", 
            team_number: 1, 
            correct: false, 
            people: []
          }, {
            valid: true, 
            last_name: "", 
            first_name: "", 
            times: [99999999], 
            team_names: [], 
            original_team: "FC Hansa Rostock", 
            run: "A", 
            team_number: 1, 
            correct: false, 
            people: []
          }
        ],
      )
    end

    context "when params are not valid" do
      it "returns failed" do
        post :check_lines, import: { discipline: "foo", gender: "male", raw_headline_columns: "team", raw_lines: "Warin" }
        expect_json_response
        expect(json_body).to include(
          success: false, 
          login: true, 
        )
      end
    end
  end

  describe 'POST scores', login: :api do
    let(:discipline) { "hb" }
    let(:attributes) { { competition_id: "5" } }
    subject { -> { post :scores, import: { discipline: discipline, gender: "male", scores: scores }.merge(attributes) } }

    context "when person exists" do
      let(:scores) { [ person_id: 13, times: ["2200"] ] }
      it { expect { subject.call }.to change(Score, :count).by(1) }
      it { expect { subject.call }.to change(Person, :count).by(0) }
    end

    context "when person does not exists" do
      let(:scores) { [ first_name: "Hans", last_name: "Wurst", times: ["2200", "2300"] ] }
      it { expect { subject.call }.to change(Score, :count).by(2) }
      it { expect { subject.call }.to change(Person, :count).by(1) }
    end

    context "when discipline is a group discipline" do
      let(:discipline) { "la" }

      context "when group_score_category_id is not set" do
        let(:scores) { [ team_id: 1, team_number: 1, times: ["2200"] ] }
        it { expect { subject.call }.to change(GroupScore, :count).by(0) }
      end

      context "when attributes are valid" do
        let(:attributes) { { group_score_category_id: "5" } }
        let(:scores) { [ team_id: 1, team_number: 1, times: ["2200"] ] }
        it { expect { subject.call }.to change(GroupScore, :count).by(1) }
      end
    end
  end
end