# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  let!(:person) { create(:person) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: person.id }
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq person
    end
  end
end
