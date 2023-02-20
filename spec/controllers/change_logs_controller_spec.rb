# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangeLogsController do
  let!(:change_logs) { create_list(:change_log, 3) }

  describe 'GET index' do
    it 'assigns rows' do
      get :index
      expect(response).to be_successful
      expect(controller.send(:collection).count).to eq 3
    end
  end

  describe 'GET show' do
    it 'redirect to index' do
      get :show, params: { id: change_logs.first.id }
      expect(response).to redirect_to(action: :index)
    end
  end
end
