require 'rails_helper'

RSpec.describe API::NationsController, type: :controller do
  describe 'GET index' do
    it "returns nations" do
      get :index
      expect_json_response
      expect(json_body[:nations].first).to eq(id: 1, iso: "de", name: "Deutschland")
    end
  end
end