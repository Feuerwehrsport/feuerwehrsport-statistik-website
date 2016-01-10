require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  describe 'GET index' do
    it "assigns rows" do
      get :index
      expect(assigns(:teams).count).to eq 95
      expect(assigns(:charts)).to be_instance_of(Chart::TeamOverview)
    end
  end

  # describe 'GET show' do
  #   it "assigns competition" do
  #     get :show, id: 1
  #     expect(assigns(:competition)).to eq Competition.find(1)
  #     expect(assigns(:calc)).to be_instance_of Calculation::Competition
  #   end
  # end
end