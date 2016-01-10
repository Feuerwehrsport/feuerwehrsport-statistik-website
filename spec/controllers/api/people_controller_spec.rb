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

  describe 'GET show' do
    it "returns person" do
      get :show, id: 1757
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Edmund",
        gender: "male",
        id: 1757,
        last_name: "Abel",
        nation_id: 1,
        translated_gender: "männlich",        
      )
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
        nation_id: 1,
        translated_gender: "männlich",
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
        nation_id: 1,
        translated_gender: "weiblich",
      )
    end
  end

  describe 'PUT update' do
    it "update person", login: :api do
      put :update, id: 1757, person: { first_name: "Vorname", last_name: "Nachname", nation_id: 2 }
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Vorname",
        gender: "male",
        id: 1757,
        last_name: "Nachname",
        nation_id: 2,
        translated_gender: "männlich",  
      )
    end
  end

  describe 'POST merge' do
    it "merge two people", login: :api do
      expect_any_instance_of(Person).to receive(:merge_to).and_call_original
      expect {
        put :merge, id: 1756, correct_person_id: 1757, always: 1
      }.to change(PersonSpelling, :count).by(1)
      
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Edmund",
        gender: "male",
        id: 1757,
        last_name: "Abel",
        nation_id: 1,
        translated_gender: "männlich",
      )
    end
  end
end