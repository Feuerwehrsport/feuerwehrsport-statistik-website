require 'rails_helper'

RSpec.describe API::ScoresController, type: :controller do
  describe 'PUT update' do
    subject { -> { put :update, id: 111, score: { team_id: "44" } } }
    it "update score", login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:score]).to include(team_id: 44)
      expect(Score.find(111).team_id).to eq 44
    end
    it_behaves_like "api user get permission error"
  end
end