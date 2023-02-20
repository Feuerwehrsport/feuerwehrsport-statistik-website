# frozen_string_literal: true
require 'rails_helper'

RSpec.describe API::GroupScoreCategoriesController, type: :controller do
  let(:group_score_category) { create(:group_score_category) }

  describe 'GET index' do
    before { group_score_category }

    it 'returns group_score_categories' do
      get :index
      expect_json_response
      expect(json_body[:group_score_categories].first).to eq(
        id: group_score_category.id,
        group_score_type: 'WKO',
        competition: '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)',
        name: 'default',
      )
    end

    context 'when discipline given' do
      let(:group_score_type) { create(:group_score_type, discipline: :gs) }
      let(:group_score_category) { create(:group_score_category, group_score_type: group_score_type) }

      it 'returns group_score_categories' do
        get :index, params: { discipline: 'gs' }
        expect_json_response
        expect(json_body[:group_score_categories].first).to eq(
          id: group_score_category.id,
          group_score_type: 'WKO',
          competition: '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)',
          name: 'default',
        )
      end
    end

    context 'when competition_id given' do
      let!(:group_score_category2) { create(:group_score_category, competition: create(:competition)) }

      it 'returns group_score_categories' do
        get :index, params: { competition_id: group_score_category2.competition.id }
        expect_json_response
        expect(json_body[:group_score_categories].first).to eq(
          id: group_score_category2.id,
          group_score_type: 'WKO',
          competition: '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)',
          name: 'default',
        )
      end
    end
  end

  describe 'POST create' do
    let(:r) { -> { post :create, params: params } }
    let(:params) do
      { group_score_category: {
        name: 'FooBar', competition_id: competition.id, group_score_type_id: group_score_type.id
      } }
    end

    let(:competition) { create(:competition) }
    let(:group_score_type) { create(:group_score_type) }

    it 'creates new group_score_category', login: :sub_admin do
      expect do
        r.call
        expect_api_login_response(created_id: GroupScoreCategory.last.id)
      end.to change(GroupScoreCategory, :count).by(1)
      expect(GroupScoreCategory.last.name).to eq 'FooBar'
      expect_change_log(after: { name: 'FooBar' }, log: 'create-groupscorecategory')
    end

    it_behaves_like 'api user get permission error'
  end
end
