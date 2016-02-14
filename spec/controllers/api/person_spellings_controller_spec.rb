require 'rails_helper'

RSpec.describe API::PersonSpellingsController, type: :controller do
  describe 'GET index' do
    it "returns person_spellings" do
      get :index
      expect_json_response
      expect(json_body[:person_spellings].first).to eq(
        person_id: 85, first_name: "Marko", last_name: "Kossack", gender: "male", official: false
      )
      expect(json_body[:person_spellings].count).to eq 14
    end
  end
end