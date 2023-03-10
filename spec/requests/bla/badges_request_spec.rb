# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bla::Badges' do
  let!(:badge) { create(:bla_badge) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/bla/badges'
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end

    context 'when xlsx requested' do
      it 'renders' do
        get '/bla/badges.xlsx'
        expect(response).to be_successful
      end
    end
  end
end
