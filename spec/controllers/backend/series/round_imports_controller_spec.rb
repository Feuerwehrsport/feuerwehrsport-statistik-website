# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::Series::RoundImportsController, type: :controller, login: :admin do
  let(:round) { create(:series_round) }

  describe 'GET new' do
    it 'shows new form' do
      get :new, params: { round_id: round }
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    let!(:score) { create(:score, :double, competition: competition) }
    let!(:group_score) { create(:group_score, :double, group_score_category: group_score_category) }
    let(:group_score_category) { create(:group_score_category, competition: competition) }
    let(:competition) { create(:competition, :score_type) }
    let(:create_attributes) { { competition_id: competition.id } }

    it 'renders create view' do
      expect do
        post :create, params: { round_id: round, series_round_import: create_attributes }
        expect(response).to render_template :create
      end.to change(Series::Cup, :count).by(0)
    end

    context 'when import_now set' do
      let(:create_attributes) { { competition_id: competition.id, import_now: '1' } }

      it 'saves and redirect to round' do
        expect do
          post :create, params: { round_id: round, series_round_import: create_attributes }
          expect(response).to redirect_to(action: :show, id: round, controller: 'backend/series/rounds')
        end.to change(Series::Cup, :count).by(1)
      end
    end
  end
end
