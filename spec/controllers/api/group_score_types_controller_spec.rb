require 'rails_helper'

RSpec.describe API::GroupScoreTypesController, type: :controller do
  describe 'GET index' do
    it "returns group_score_types" do
      get :index
      expect_json_response
      expect(json_body[:group_score_types].first).to eq(
        discipline: "la",
        id: 1,
        name: "WKO DIN-Pumpe",
        regular: true,
      )
    end

    context "when discipline given" do
      before { GroupScoreCategory.last.update!(group_score_type: GroupScoreType.where(discipline: :gs).first) }
      it "returns group_score_categories" do
        get :index, discipline: "gs"
        expect_json_response
        expect(json_body[:group_score_types].first).to eq(
          discipline: "gs",
          id: 2,
          name: "WKO",
          regular: true,
        )
      end
    end
  end
end