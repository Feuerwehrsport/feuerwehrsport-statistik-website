# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ipo::RegistrationsController do
  let(:resource_attrs) do
    {
      team_name: 'Warin',
      name: 'Limbach, Georg',
      locality: 'Rostock',
      phone_number: '0190 123456',
      email_address: 'georf@georf.de',
      youth_team: true,
      female_team: false,
      male_team: true,
      terms_of_service: true,

    }
  end

  context 'when admin logged in', login: :admin do
    it_behaves_like 'a backend resource controller' do
      let(:resource_name) { :ipo_registration }
      let(:change_log_enabled) { false }
      let(:resource_attributes) { resource_attrs }
    end
  end

  context 'when nobody logged in' do
    describe 'GET new' do
      it 'shows new form' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'POST create' do
      it 'creates new resource' do
        allow(controller).to receive(:registration_open?).and_return(true)
        expect do
          post :create, params: { ipo_registration: resource_attrs }
          expect(response).to redirect_to(action: :finish)
        end.to change(Ipo::Registration, :count).by(1)
      end
    end

    describe 'GET finish' do
      it 'returns resource' do
        get :finish
        expect(response).to be_successful
      end
    end
  end
end
