require 'rails_helper'

RSpec.describe API::EventsController, type: :controller do
  let(:event) { create(:event) }
  describe 'POST create' do
    subject { -> { post :create, event: { name: 'Wurstevent' } } }
    it 'creates new event', login: :sub_admin do
      expect do
        subject.call
        expect_api_login_response
      end.to change(Event, :count).by(1)
    end
    it_behaves_like 'api user get permission error'
  end

  describe 'GET show' do
    it 'returns event' do
      get :show, id: event.id
      expect_json_response
      expect(json_body[:event]).to eq(id: event.id, name: 'D-Cup')
    end
  end

  describe 'GET index' do
    before { event }
    it 'returns events' do
      get :index
      expect_json_response
      expect(json_body[:events]).to eq([id: event.id, name: 'D-Cup'])
    end
  end
end
