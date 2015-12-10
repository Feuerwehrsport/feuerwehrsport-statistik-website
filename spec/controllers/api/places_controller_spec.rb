require 'rails_helper'

RSpec.describe API::PlacesController, type: :controller do
  describe 'GET index' do
    it "returns places" do
      get :index
      expect_json_response
      expect(json_body[:places].first).to include id: 1, name: "Charlottenthal"
    end
  end
end