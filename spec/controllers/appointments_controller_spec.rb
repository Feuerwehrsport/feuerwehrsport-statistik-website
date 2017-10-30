require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do
  let!(:appointment) { create(:appointment) }
  describe 'GET index' do
    it 'assigns rows' do
      Timecop.freeze(Date.parse('2013-01-01')) do
        get :index
        expect(response).to be_success
        expect(controller.send(:collection).count).to eq 1
      end
    end

    context 'when ics format requested' do
      it 'returns appointsments as ics file' do
        Timecop.freeze(Date.parse('2013-01-01')) do
          get :index, format: :ics
          expect_ics_response(appointment)
        end
      end
    end
  end

  describe 'GET show' do
    it 'assigns appointment' do
      get :show, id: appointment.id
      expect(response).to be_success
      expect(controller.send(:resource)).to eq appointment
    end

    context 'when ics format requested' do
      it 'returns appointment as ics file' do
        Timecop.freeze(Date.parse('2013-01-01')) do
          get :show, id: appointment.id, format: :ics
          expect_ics_response(appointment)
        end
      end
    end
  end
end

def expect_ics_response(appointment)
  expect(response).to be_success
  expect(response.header['Content-Type']).to eq 'text/calendar; charset=utf-8'
  expect(response.body).to include(
    "BEGIN:VCALENDAR\r\n" \
    "VERSION:2.0\r\n" \
    "PRODID:icalendar-ruby\r\n" \
    "CALSCALE:GREGORIAN\r\n",
  )
  expect(response.body).to include(
    "BEGIN:VEVENT\r\n" \
    "DTSTAMP:20121231T230000Z\r\n" \
    "UID:http://test.host/appointments/#{appointment.id}\r\n" \
    "DTSTART:20130921T000000\r\n",
  )
  expect(response.body).to include(
    "DESCRIPTION:Am 21.09.2013 findet das Finale des Deutschland-Cups in Charlot\r\n" \
    " tenthal statt.\r\n",
  )
  expect(response.body).to include(
    "LOCATION:Charlottenthal\r\n" \
   "SUMMARY:Finale D-Cup in Charlottenthal - D-Cup\r\n" \
   "URL:http://test.host/appointments/#{appointment.id}\r\n" \
   "END:VEVENT\r\n" \
   "END:VCALENDAR\r\n",
  )
end
