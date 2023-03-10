# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ChangeLogs' do
  let!(:change_logs) { create_list(:change_log, 3) }

  describe 'GET index' do
    it 'assigns rows' do
      get '/change_logs'
      expect(response).to be_successful
      expect(controller.send(:collection).count).to eq 3
    end
  end

  describe 'GET show' do
    it 'redirect to index' do
      get "/change_logs/#{change_logs.first.id}"
      expect(response).to redirect_to(action: :index)
    end
  end
end
