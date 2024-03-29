# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Series::Cups', login: :admin do
  let(:cup) { create(:series_cup) }

  describe 'DELETE destroy' do
    before { cup }

    it 'deletes cup' do
      expect do
        delete "/backend/series/cups/#{cup.id}"
        expect(response).to redirect_to backend_series_round_path(cup.round)
      end.to change(Series::Cup, :count).by(-1)
    end
  end
end
