require 'rails_helper'

RSpec.describe API::CompetitionsController, type: :controller do
  describe 'GET show' do
    it "returns competition" do
      get :show, id: 1
      expect(json_body[:competition]).to eq(
        id: 1, 
        name: "", 
        place: "Charlottenthal", 
        event: "D-Cup", 
        date: "2006-06-10"
      )
    end
  end
end