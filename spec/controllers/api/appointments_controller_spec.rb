require 'rails_helper'

RSpec.describe API::AppointmentsController, type: :controller do
  describe 'POST create' do
    it "creates new appointment", login: :api do
      expect {
        post :create, appointment: { name: "Termin1", description: "Beschreibung", dated_at: "2016-02-29" }
        expect_api_response
      }.to change(Appointment, :count).by(1)
    end
  end

  describe 'GET show' do
    it "returns appointment" do
      get :show, id: 1
      expect_api_response login: false, resource_name: "appointment", appointment: {
        id: 1, 
        name: "Finale D-Cup in Charlottenthal", 
        place_id: 1, 
        event_id: 1, 
        place: "Charlottenthal", 
        event: "D-Cup", 
        disciplines: "gs,hb,hl,la", 
        dated_at: "2013-09-21",
        description: "Am 21.09.2013 findet das Finale des Deutschland-Cups in Charlottenthal statt.",
      }
    end
  end
end