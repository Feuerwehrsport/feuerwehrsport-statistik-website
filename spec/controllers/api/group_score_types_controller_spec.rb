require 'rails_helper'

RSpec.describe API::GroupScoreTypesController, type: :controller do
  describe 'POST create' do
    subject { -> { post :create, group_score_type: { name: "Extrapokal", discipline: "la" } } }
    it "creates new group_score_type", login: :sub_admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(GroupScoreType, :count).by(1)
    end
    it_behaves_like "api user get permission error"
  end

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