# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CompetitionsController do
  let(:competition) { create(:competition, :score_type, :fake_count) }

  describe 'POST create' do
    let(:r) { -> { post :create, params: params } }

    let(:params) { { competition: { name: 'Extrapokal', place_id: place.id, event_id: event.id, date: '2014-01-29' } } }
    let(:place) { create(:place) }
    let(:event) { create(:event) }

    it 'creates new competition', login: :sub_admin do
      expect do
        r.call
        expect_api_login_response(created_id: Competition.last.id)
      end.to change(Competition, :count).by(1)
      expect_change_log(after: { name: 'Extrapokal' }, log: 'create-competition')
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET show' do
    it 'returns competition' do
      get :show, params: { id: competition.id }
      expect_json_response
      expect(json_body[:competition]).to eq(
        id: competition.id,
        name: 'Erster Lauf',
        place: 'Charlottenthal',
        event: 'D-Cup',
        date: '2017-05-01',
        hint_content: '',
        published_at: nil,
        score_count: {
          hb: { female: 0, male: 0 },
          hl: { female: 0, male: 0 },
          gs: { female: 0, male: 0 },
          fs: { female: 0, male: 0 },
          la: { female: 0, male: 0 },
        },
        score_type_id: competition.score_type_id,
        score_type: '10/8/6',
      )
    end
  end

  describe 'GET index' do
    before { competition }

    it 'returns competitions' do
      get :index
      expect_json_response
      expect(json_body[:competitions].first).to eq(
        id: competition.id,
        name: 'Erster Lauf',
        place: 'Charlottenthal',
        event: 'D-Cup',
        date: '2017-05-01',
        hint_content: '',
      )
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put :update, params: { id: competition.id, competition: { name: 'toller Wettkampf' } } } }

    it 'update competition', login: :sub_admin do
      r.call
      expect_json_response
      expect(json_body[:competition]).to eq(
        id: competition.id,
        name: 'toller Wettkampf',
        place: 'Charlottenthal',
        event: 'D-Cup',
        date: '2017-05-01',
        hint_content: '',
      )
      expect_change_log(before: { name: 'Erster Lauf' }, after: { name: 'toller Wettkampf' }, log: 'update-competition')
    end

    it_behaves_like 'api user get permission error'
  end
end
