require 'rails_helper'

RSpec.describe API::CompetitionsController, type: :controller do
  describe 'POST create' do
    subject { -> { post :create, competition: { name: "Extrapokal", place_id: "1", event_id: "1", date: "2014-01-29" } } }
    it "creates new competition", login: :sub_admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Competition, :count).by(1)
    end
    it_behaves_like "api user get permission error"
  end

  describe 'GET show' do
    it "returns competition" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:competition]).to eq(
        id: 1, 
        name: "", 
        place: "Charlottenthal", 
        event: "D-Cup", 
        date: "2006-06-10",
        hint_content: "",
        published_at: nil,
        score_count: {
          hb: {female: 62, male: 88}, 
          hl: {female: 0, male: 83}, 
          gs: {female: 0, male: 0}, 
          fs: {female: 0, male: 0}, 
          la: {female: 0, male: 0}
        },
        score_type_id: 2, 
        score_type: "10/8/4",
      )
    end
  end

  describe 'GET index' do
    it "returns competitions" do
      get :index
      expect_json_response
      expect(json_body[:competitions].first).to eq(
        id: 1, 
        name: "", 
        place: "Charlottenthal", 
        event: "D-Cup", 
        date: "2006-06-10",
        hint_content: "",
      )
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: 1, competition: { name: "toller Wettkampf" } } }
    it "update competition", login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:competition]).to eq(
        id: 1, 
        name: "toller Wettkampf", 
        place: "Charlottenthal", 
        event: "D-Cup", 
        date: "2006-06-10",
        hint_content: "",
      )
    end
    it_behaves_like "api user get permission error"
  end
end