require 'rails_helper'

RSpec.describe API::PlacesController, type: :controller do
  describe 'GET index' do
    it "returns places" do
      get :index
      expect_json_response
      expect(json_body[:places].first).to eq(id: 268, name: "Almaty (KZ)")
    end
  end
end