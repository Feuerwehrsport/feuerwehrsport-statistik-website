require 'rails_helper'

RSpec.describe API::LinksController, type: :controller do
  describe 'POST create' do
    it "creates new link", login: :api do
      expect {
        post :create, link: { label: "Linkname", url: "http://foobar", linkable_id: "1", linkable_type: "Team"}
        expect_api_response
      }.to change(Link, :count).by(1)
    end
  end
end