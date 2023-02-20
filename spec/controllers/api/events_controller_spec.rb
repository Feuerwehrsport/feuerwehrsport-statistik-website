# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::EventsController do
  let(:event) { create(:event) }

  describe 'POST create' do
    let(:r) { -> { post :create, params: { event: { name: 'Wurstevent' } } } }

    it 'creates new event', login: :sub_admin do
      expect do
        r.call
        expect_api_login_response(created_id: Event.last.id)
      end.to change(Event, :count).by(1)
      expect_change_log(after: { name: 'Wurstevent' }, log: 'create-event')
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET show' do
    it 'returns event' do
      get :show, params: { id: event.id }
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
