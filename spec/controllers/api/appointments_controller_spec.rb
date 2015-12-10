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
end