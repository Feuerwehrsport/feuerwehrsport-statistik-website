require 'rails_helper'

RSpec.describe Registrations::CompetitionsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET new' do
    it 'redirects' do
      get :new
      expect(response).to redirect_to(action: :new_select_template)
    end
  end

  describe 'GET new_select_template' do
    it 'renders template select' do
      get :new_select_template
      expect(response).to be_success
    end
  end

  describe 'POST create' do
    context 'when tempate selected' do
      it 'renders new' do
        expect_any_instance_of(Registrations::Competition).not_to receive(:save)
        post :create, from_template: true, registrations_competition: { name: 'foo' }
        expect(response).to be_success
      end
    end

    context 'when real save' do
      it 'saves' do
        expect do
          expect_any_instance_of(Registrations::Competition).to receive(:save).and_call_original
          post :create, registrations_competition: { name: 'foo', place: 'Warin', date: '2018-01-01' }
          expect(response).to redirect_to(action: :show, id: Registrations::Competition.last.id)
        end.to change(Registrations::Competition, :count).by(1)
      end
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, id: competition.id
      expect(controller.send(:resource)).to be_a Registrations::Competition
      expect(response).to be_success
      expect(response.content_type).to eq 'text/html'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get :show, id: competition.id, format: :pdf
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_success
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq('inline; filename="d-cup-21-03-2018.pdf"')
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get :edit, id: competition.id
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, id: competition.id, registrations_competition: { name: 'new-name' }
      expect(response).to redirect_to(action: :show, id: competition.id)
      expect(competition.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      competition # to load instance
      expect do
        delete :destroy, id: competition.id
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Competition, :count).by(-1)
    end
  end
end
