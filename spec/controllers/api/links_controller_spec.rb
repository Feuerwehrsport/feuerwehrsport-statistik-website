require 'rails_helper'

RSpec.describe API::LinksController, type: :controller do
  let(:link) { create(:link) }
  let(:team) { create(:team) }

  describe 'POST create' do
    it 'creates new link', login: :api do
      expect do
        post :create, params: {
          link: { label: 'Linkname', url: 'http://foobar', linkable_id: team.id, linkable_type: 'Team' },
        }
        expect_api_login_response(created_id: Link.last.id)
      end.to change(Link, :count).by(1)
      expect_change_log(after: { label: 'Linkname' }, log: 'create-link')
    end
  end

  describe 'GET show', login: :api do
    it 'returns link' do
      get :show, params: { id: link.id }
      expect_json_response
      expect(json_body[:link]).to eq(
        id: link.id,
        label: 'Bericht auf Feuerwehrsport Team-MV',
        linkable_id: link.linkable_id,
        linkable_type: 'Competition',
        linkable_url: "http://test.host/competitions/#{link.linkable_id}",
        url: 'http://www.feuerwehrsport-teammv.de/2012/08/24-08-2012-3-mv-steigercup-kagsdorf/',
      )
    end
  end

  describe 'DELETE destroy' do
    let(:r) { -> { delete :destroy, params: { id: link.id } } }

    before { link }

    it 'destroys link', login: :sub_admin do
      expect do
        r.call
        expect_json_response
      end.to change(Link, :count).by(-1)
      expect_change_log(before: {}, log: 'destroy-link')
    end

    it_behaves_like 'api user get permission error'
  end
end
