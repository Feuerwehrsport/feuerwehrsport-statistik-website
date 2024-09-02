# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations::Competitions', login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/registrations/competitions'
      expect(response).to be_successful
    end
  end

  describe 'GET new' do
    it 'redirects' do
      get '/registrations/competitions/new'
      expect(response).to redirect_to(action: :new_select_template)
    end
  end

  describe 'GET new_select_template' do
    it 'renders template select' do
      get '/registrations/competitions/new_select_template'
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    context 'when tempate selected' do
      it 'renders new' do
        expect_any_instance_of(Registrations::Competition).not_to receive(:save)
        post '/registrations/competitions', params: { first: '1', registrations_competition: { name: 'foo' } }
        expect(response).to be_successful
      end
    end

    context 'when real save' do
      it 'saves' do
        expect do
          expect_any_instance_of(Registrations::Competition).to receive(:save).and_call_original
          post '/registrations/competitions',
               params: { registrations_competition: { name: 'foo', place: 'Warin', date: '2028-01-01' } }
          expect(response).to redirect_to(action: :show, id: Registrations::Competition.last.id)
        end.to change(Registrations::Competition, :count).by(1)
      end
    end
  end

  describe 'GET show' do
    before { Timecop.freeze(Date.parse('2018-03-21')) }

    after { Timecop.return }

    it 'assigns resource' do
      get "/registrations/competitions/#{competition.id}"
      expect(controller.send(:resource)).to be_a Registrations::Competition
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get "/registrations/competitions/#{competition.id}.pdf"
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq(
          "inline; filename=\"d-cup-21-03-2018.pdf\"; filename*=UTF-8''d-cup-21-03-2018.pdf",
        )
      end
    end

    context 'when xlsx requested' do
      it 'sends xlsx' do
        get "/registrations/competitions/#{competition.id}.xlsx"
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_successful
        expect(response.content_type).to eq(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8',
        )
        expect(response.headers['Content-Disposition']).to eq('attachment; filename="d-cup-21-03-2018.xlsx"')
        expect(response.body.length).to be > 2000
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get "/registrations/competitions/#{competition.id}/edit"
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch "/registrations/competitions/#{competition.id}", params: { registrations_competition: { name: 'new-name' } }
      expect(response).to redirect_to(action: :show, id: competition.id)
      expect(competition.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      competition # to load instance
      expect do
        delete "/registrations/competitions/#{competition.id}"
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Competition, :count).by(-1)
    end
  end

  describe 'GET slug_handle' do
    it 'redirects' do
      get "/wa/#{competition.slug}"
      expect(response).to redirect_to(registrations_competition_path(competition.id))
    end
  end
end
