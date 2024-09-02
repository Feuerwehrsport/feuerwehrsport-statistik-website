# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Appointments' do
  let!(:appointment) { create(:appointment) }

  describe 'GET index' do
    it 'assigns rows' do
      Timecop.freeze(Date.parse('2013-01-01')) do
        get '/appointments'
        expect(response).to be_successful
        expect(controller.send(:collection).count).to eq 1
      end
    end
  end
end
