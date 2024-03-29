# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Appointments' do
  let(:appointment) { create(:appointment, creator:) }
  let(:creator) { create(:admin_user, :sub_admin) }

  let(:expected_attributes) do
    {
      id: appointment.id,
      name: 'Finale D-Cup in Charlottenthal',
      event_id: appointment.event.id,
      place: 'Charlottenthal',
      event: 'D-Cup',
      disciplines: 'gs,hb,hl,la',
      dated_at: '2013-09-21',
      description: 'Am 21.09.2013 findet das Finale des Deutschland-Cups in Charlottenthal statt.',
      updateable: false,
    }
  end

  describe 'POST create' do
    let(:attributes) { { name: 'Termin1', description: 'Beschreibung', dated_at: '2016-02-29' } }

    it 'creates new appointment', login: :api do
      expect do
        post '/api/appointments', params: { appointment: attributes }
        expect_api_login_response(created_id: Appointment.last.id)
      end.to change(Appointment, :count).by(1)
      expect_change_log(after: attributes, log: 'create-appointment')
    end
  end

  describe 'GET show' do
    it 'returns appointment' do
      get "/api/appointments/#{appointment.id}"
      expect_api_not_login_response resource_name: 'appointment', appointment: expected_attributes
    end

    context 'when creator is api user', login: :api do
      let(:creator) { login_user }

      it 'returns appointment' do
        get "/api/appointments/#{appointment.id}"
        expect_api_login_response resource_name: 'appointment', appointment: expected_attributes.merge(
          updateable: true,
        )
      end
    end
  end

  describe 'PUT update' do
    let(:r) { -> { put "/api/appointments/#{appointment.id}", params: { appointment: appointment_changes } } }

    let(:appointment_changes) { { name: 'Termin1', description: 'Beschreibung', dated_at: '2016-02-29' } }

    it 'update appointment', login: :sub_admin do
      r.call
      expect_api_login_response(
        resource_name: 'appointment',
        appointment: expected_attributes.merge(appointment_changes.merge(updateable: true)),
      )
      expect_change_log(
        before: { name: 'Finale D-Cup in Charlottenthal' },
        after: { name: 'Termin1' },
        log: 'update-appointment',
      )
    end

    it_behaves_like 'api user get permission error'
  end

  describe 'GET index' do
    before { appointment }

    it 'returns appointments' do
      get '/api/appointments'
      expect_api_not_login_response(collection_name: 'appointments',
                                    appointments: [expected_attributes.merge(updateable: nil)])
    end
  end
end
