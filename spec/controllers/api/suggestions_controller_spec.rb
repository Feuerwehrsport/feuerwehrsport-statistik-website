require 'rails_helper'

RSpec.describe API::SuggestionsController, type: :controller do
  describe 'POST create' do
    subject { -> { post :people } }
    context "when extended" do
      it "returns team" do
        subject.call
        expect(json_body[:people]).to eq [
          {
            id: 1, 
            last_name: "Klos", 
            first_name: "Mareen", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Buckow"]
          }, {
            id: 2, 
            last_name: "Stanitzek", 
            first_name: "Vanessa", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Buckow", "MOL"]
          }, {
            id: 3, 
            last_name: "Redmann", 
            first_name: "Sandra", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Buckow", "MOL"]
          }, {
            id: 4, 
            last_name: "Müller", 
            first_name: "Melanie", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team Lausitz"]
          }, {
            id: 6, 
            last_name: "Koch", 
            first_name: "Manuela", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team Lausitz"]
          }, {
            id: 8, 
            last_name: "Rost", 
            first_name: "Stephanie", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team MV", "Charlottenthal"]
          }, {
            id: 10, 
            last_name: "Schmecht", 
            first_name: "Sabine", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team MV", "Charlottenthal"]
          }, {
            id: 11, 
            last_name: "Krüger", 
            first_name: "Simone", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team MV", "Charlottenthal"]
          }, {
            id: 12, 
            last_name: "Herold", 
            first_name: "Kerstin", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team MV", "Thalheim", "Charlottenthal"]
          }, {
            id: 13, 
            last_name: "Haase", 
            first_name: "Christine", 
            gender: "female", 
            translated_gender: "weiblich", 
            teams: ["Team MV"]
          }
        ]
      end
    end
  end
end