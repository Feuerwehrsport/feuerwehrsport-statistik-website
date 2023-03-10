# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Series::Rounds' do
  let!(:round) { create(:series_round) }
  let!(:cup) { create(:series_cup, round:) }

  describe 'GET index' do
    it 'assigns collection' do
      get "/series/#{round.kind.slug}"
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/series/rounds/#{round.id}"
      expect(controller.send(:resource)).to be_a Series::Round
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get "/series/rounds/#{round.id}.pdf"
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
