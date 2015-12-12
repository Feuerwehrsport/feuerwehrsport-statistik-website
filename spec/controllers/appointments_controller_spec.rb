require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do
  describe 'GET index' do
    it "assigns rows" do
      get :index
      expect(assigns(:rows).count).to eq 10
    end

    context "when ics format requested" do
      it "returns appointsments as ics file" do
        get :index, format: :ics
        expect(response.header['Content-Type']).to eq 'text/calendar; charset=utf-8'
        expect(response.body).to include "BEGIN:VCALENDAR"
        expect(response.body).to include "METHOD:PUBLISH"
      end
    end
  end

  describe 'GET show' do
    it "assigns appointment" do
      get :show, id: 1
      expect(assigns(:appointment)).to eq Appointment.find(1)
    end

    context "when ics format requested" do
      it "returns appointsment as ics file" do
        get :show, id: 1, format: :ics
        expect(response.header['Content-Type']).to eq 'text/calendar; charset=utf-8'
        expect(response.body).to include "BEGIN:VCALENDAR"
        expect(response.body).to include "METHOD:REQUEST"
      end
    end
  end
end