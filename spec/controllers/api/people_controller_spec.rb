require 'rails_helper'

RSpec.describe API::PeopleController, type: :controller do
  describe 'POST create' do
    it "creates new person", login: :api do
      expect {
        post :create, person: { first_name: "Alfred", last_name: "Meier", gender: "male", nation_id: 1 }
        expect_api_response
      }.to change(Person, :count).by(1)
    end
  end

  describe 'GET index' do
    it "returns people" do
      get :index
      expect_json_response
      expect(json_body[:people].count).to eq 2178
      expect(json_body[:people].first).to eq(
        first_name: "Edmund",
        gender: "male",
        id: 1757,
        last_name: "Abel",
        nation_id: 1
      )
    end

    it "returns only gendered people" do
      get :index, gender: :female
      expect_json_response
      expect(json_body[:people].count).to eq 670
      expect(json_body[:people].first).to eq(
        first_name: "Frederike",
        gender: "female",
        id: 1858,
        last_name: "Adamczak",
        nation_id: 1
      )
    end
  end
end