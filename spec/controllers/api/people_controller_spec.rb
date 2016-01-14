require 'rails_helper'

RSpec.describe API::PeopleController, type: :controller do
  describe 'POST create' do
    it "creates new person", login: :api do
      expect {
        post :create, person: { first_name: "Alfred", last_name: "Meier", gender: "male", nation_id: 1 }
        expect_api_login_response
      }.to change(Person, :count).by(1)
    end
  end

  describe 'GET show' do
    it "returns person" do
      get :show, id: 1
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Mareen",
        gender: "female",
        id: 1,
        last_name: "Klos",
        nation_id: 1,
        translated_gender: "weiblich",        
      )
    end
  end

  describe 'GET index' do
    it "returns people" do
      get :index
      expect_json_response
      expect(json_body[:people].count).to eq 94
      expect(json_body[:people].first).to eq(
        first_name: "Diana",
        gender: "female",
        id: 37,
        last_name: "Ahnert",
        nation_id: 1,
        translated_gender: "weiblich",
      )
    end

    it "returns only gendered people" do
      get :index, gender: :male
      expect_json_response
      expect(json_body[:people].count).to eq 59
      expect(json_body[:people].first).to eq(
        first_name: "Daniel",
        gender: "male",
        id: 86,
        last_name: "Arlt",
        nation_id: 1,
        translated_gender: "männlich",
      )
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: 1, person: { first_name: "Vorname", last_name: "Nachname", nation_id: 2 } } }
    it "update person", login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Vorname",
        gender: "female",
        id: 1,
        last_name: "Nachname",
        nation_id: 2,
        translated_gender: "weiblich",  
      )
    end
    it_behaves_like "api user get permission error"
  end

  describe 'POST merge' do
    subject { -> { put :merge, id: 86, correct_person_id: 37, always: 1 } }
    it "merge two people", login: :sub_admin do
      expect_any_instance_of(Person).to receive(:merge_to).and_call_original
      expect {
        subject.call
      }.to change(PersonSpelling, :count).by(1)
      
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: "Diana",
        gender: "female",
        id: 37,
        last_name: "Ahnert",
        nation_id: 1,
        translated_gender: "weiblich",
      )
    end
    it_behaves_like "api user get permission error"
  end
end