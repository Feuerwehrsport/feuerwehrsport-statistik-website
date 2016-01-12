require 'rails_helper'

RSpec.describe API::ImportsController, type: :controller do
  describe 'POST check_lines', login: :api do
    let(:raw_lines) { "Warin;foo;22\nFF Wurststadt;bla;44\nFC Hansa Rostock;blub;D" }
    it "returns group_score" do
      post :check_lines, import: { discipline: "la", gender: "male", seperator: ";", raw_headline_columns: "team;col;time", raw_lines: raw_lines }
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
        expect_json_response(
          success: false, 
          login: true, 
          message: "Lines muss ausgefüllt werden, Headline columns muss ausgefüllt werden, Headline columns  has not all required columns (time, first_name, last_name for foo), Seperator muss ausgefüllt werden, and Disziplin ist kein gültiger Wert"
        )
      end
    end
  end
end