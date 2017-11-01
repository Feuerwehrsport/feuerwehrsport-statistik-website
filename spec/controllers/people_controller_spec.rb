require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  let!(:person) { create(:person) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
      expect(controller.send(:collection).length).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: person.id
      expect(response).to be_success
      expect(controller.send(:resource)).to eq person
    end
  end
end