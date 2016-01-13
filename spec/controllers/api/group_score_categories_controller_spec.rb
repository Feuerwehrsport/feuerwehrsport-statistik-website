require 'rails_helper'

RSpec.describe API::GroupScoreCategoriesController, type: :controller do
  describe 'GET index' do
    it "returns group_score_categories" do
      get :index
      expect_json_response
      expect(json_body[:group_score_categories].first).to eq(
        id: 1, 
        group_score_type: "WKO DIN-Pumpe", 
        competition: "14.06.2008 - Charlottenthal, D-Cup", 
        name: "default",
      )
    end

    context "when discipline given" do
      before { GroupScoreCategory.last.update!(group_score_type: GroupScoreType.where(discipline: :gs).first) }
      it "returns group_score_categories" do
        get :index, discipline: "gs"
        expect_json_response
        expect(json_body[:group_score_categories].first).to eq(
          id: 99, 
          group_score_type: "WKO", 
          competition: "16.06.2012 - Doberlug-Kirchhain, Stadtausscheid", 
          name: "default",
        )
      end
    end

    context "when competition_id given" do
      it "returns group_score_categories" do
        get :index, competition_id: "40"
        expect_json_response
        expect(json_body[:group_score_categories].first).to eq(
          id: 25, 
          group_score_type: "WKO DIN-Pumpe", 
          competition: "08.05.2010 - Buch, Pokallauf", 
          name: "default",
        )
      end
    end
  end

  describe 'POST create' do
    it "creates new group_score_category", login: :api do
      expect {
        post :create, group_score_category: { name: "FooBar", competition_id: 1, group_score_type_id: 1 }
        expect_api_login_response
      }.to change(GroupScoreCategory, :count).by(1)
      expect(GroupScoreCategory.last.name).to eq "FooBar"
    end
  end
end