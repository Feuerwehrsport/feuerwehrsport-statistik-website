# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Registrations::CompetitionsController, type: :controller, login: :user do
  let(:competition) { create(:registrations_competition) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_successful
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
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    context 'when tempate selected' do
      it 'renders new' do
        expect_any_instance_of(Registrations::Competition).not_to receive(:save)
        post :create, params: { from_template: true, registrations_competition: { name: 'foo' } }
        expect(response).to be_successful
      end
    end

    context 'when real save' do
      it 'saves' do
        expect do
          expect_any_instance_of(Registrations::Competition).to receive(:save).and_call_original
          post :create, params: { registrations_competition: { name: 'foo', place: 'Warin', date: '2028-01-01' } }
          expect(response).to redirect_to(action: :show, id: Registrations::Competition.last.id)
        end.to change(Registrations::Competition, :count).by(1)
      end
    end
  end

  describe 'GET show' do
    before { Timecop.freeze(Date.parse('2018-03-21')) }

    after { Timecop.return }

    it 'assigns resource' do
      get :show, params: { id: competition.id }
      expect(controller.send(:resource)).to be_a Registrations::Competition
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/html'
    end

    context 'when pdf requested' do
      it 'sends pdf' do
        get :show, params: { id: competition.id, format: :pdf }
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers['Content-Disposition']).to eq('inline; filename="d-cup-21-03-2018.pdf"')
      end
    end

    context 'when wettkampf_manager_import requested' do
      it 'sends wettkampf_manager_import' do
        get :show, params: { id: competition.id, format: :wettkampf_manager_import }
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_successful
        expect(response.content_type).to eq 'text/wettkampf_manager_format'
        expect(response.headers['Content-Disposition']).to eq 'attachment; ' \
        'filename="d-cup-21-03-2018.wettkampf_manager_import"'
        expect(response.body).to eq '{"name":"D-Cup","place":"Ort","date":"2018-03-21","description":"","teams":[],' \
          '"assessments":[],"people":[],"person_tag_list":[],"team_tag_list":[]}'
      end
    end

    context 'when xlsx requested' do
      render_views
      it 'sends xlsx' do
        get :show, params: { id: competition.id, format: :xlsx }
        expect(controller.send(:resource)).to be_a Registrations::Competition
        expect(response).to be_successful
        expect(response.content_type).to eq 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        expect(response.headers['Content-Disposition']).to eq('attachment; filename="d-cup-21-03-2018.xlsx"')
        expect(response.body.length).to be > 4000
      end
    end
  end

  describe 'GET edit' do
    it 'renders form' do
      get :edit, params: { id: competition.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH update' do
    it 'updates' do
      patch :update, params: { id: competition.id, registrations_competition: { name: 'new-name' } }
      expect(response).to redirect_to(action: :show, id: competition.id)
      expect(competition.reload.name).to eq 'new-name'
    end
  end

  describe 'DELETE destroy' do
    it 'destroys' do
      competition # to load instance
      expect do
        delete :destroy, params: { id: competition.id }
        expect(response).to redirect_to(action: :index)
      end.to change(Registrations::Competition, :count).by(-1)
    end
  end

  describe 'GET slug_handle' do
    it 'redirects' do
      get :slug_handle, params: { slug: competition.slug }
      expect(response).to redirect_to(registrations_competition_path(competition.id))
    end
  end
end
