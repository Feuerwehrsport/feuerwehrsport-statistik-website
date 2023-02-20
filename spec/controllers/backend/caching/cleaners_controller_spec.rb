# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::Caching::CleanersController, type: :controller, login: :sub_admin do
  describe 'GET new' do
    it 'shows new form' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'creates new resource' do
      post :create
      expect(response).to redirect_to(backend_root_path)
      expect_no_change_log
    end
  end
end
