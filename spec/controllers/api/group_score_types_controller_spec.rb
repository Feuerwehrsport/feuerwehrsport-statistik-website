# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::GroupScoreTypesController do
  let(:group_score_type) { create(:group_score_type) }

  describe 'POST create' do
    let(:r) { -> { post :create, params: { group_score_type: { name: 'Extrapokal', discipline: 'la' } } } }

    it 'creates new group_score_type', login: :sub_admin do
      expect do
        r.call
        expect_api_login_response(created_id: GroupScoreType.last.id)
      end.to change(GroupScoreType, :count).by(1)
      expect_change_log(after: { name: 'Extrapokal' }, log: 'create-groupscoretype')
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET index' do
    before { group_score_type }

    it 'returns group_score_types' do
      get :index
      expect_json_response
      expect(json_body[:group_score_types].first).to eq(
        discipline: 'la',
        id: group_score_type.id,
        name: 'WKO',
        regular: true,
      )
    end

    context 'when discipline given' do
      let(:group_score_type) { create(:group_score_type, discipline: :gs) }

      it 'returns group_score_categories' do
        get :index, params: { discipline: 'gs' }
        expect_json_response
        expect(json_body[:group_score_types].first).to eq(
          discipline: 'gs',
          id: group_score_type.id,
          name: 'WKO',
          regular: true,
        )
      end
    end
  end
end
