# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::RoundsController do
  let!(:round) { create(:series_round) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(assigns(:rounds).keys).to eq ['D-Cup']
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: round.id }
      expect(controller.send(:resource)).to be_a Series::Round
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get :show, params: { id: round.id, format: :pdf }
        expect(controller.send(:resource)).to be_a Series::Round
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq(
          "inline; filename=\"d-cup-2016.pdf\"; filename*=UTF-8''d-cup-2016.pdf",
        )
      end
    end
  end
end
