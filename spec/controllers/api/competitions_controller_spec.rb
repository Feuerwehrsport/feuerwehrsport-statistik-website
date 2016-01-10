require 'rails_helper'

RSpec.describe API::CompetitionsController, type: :controller do
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
      )
    end
  end

  describe 'PUT update' do
    it "update competition", login: :api do
      put :update, id: 1, competition: { name: "toller Wettkampf" }
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
  end
end