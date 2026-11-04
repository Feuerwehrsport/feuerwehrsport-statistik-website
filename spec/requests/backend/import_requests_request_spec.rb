# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::ImportRequests', login: :sub_admin do
  let(:place) { create(:place) }
  let(:event) { create(:event) }
  let!(:admin) { create(:admin_user, :admin) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        url: 'http://foobar.com/test',
        place_id: place.id,
        event_id: event.id,
        date: '2013-09-21',
        description: 'Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.',
      }
    end
  end

  describe 'GET decide_login' do
    it 'redirects to new when logged in' do
      get '/backend/import_requests/decide_login'
      expect(response).to redirect_to(action: :new)
    end
  end

  describe 'POST create' do
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/testfile.pdf'), 'application/pdf') }
    let(:import_request_params) do
      {
        url: 'http://foobar.com/test', place_id: place.id, event_id: event.id, date: '2013-09-21',
        description: 'Beschreibung', import_request_files_attributes: { '0' => { file: } }
      }
    end

    it 'assigns current user and sends mail to admins' do
      expect do
        post '/backend/import_requests', params: { import_request: import_request_params }
      end.to have_enqueued_mail(ImportRequestMailer, :new_request)
      import_request = ImportRequest.last
      expect(import_request.admin_user).to eq login_user
      expect(import_request.import_request_files.count).to eq 1
    end
  end

  describe 'GET show' do
    let(:import_request) { create(:import_request, date: Date.parse('2017-05-03')) }
    let!(:nearby_competition) { create(:competition, date: Date.parse('2017-05-01'), name: 'Nah dran') }
    let!(:far_competition) { create(:competition, date: Date.parse('2017-06-01'), name: 'Weit weg') }

    it 'assigns nearby competitions' do
      get "/backend/import_requests/#{import_request.id}"
      expect(response).to be_successful
      expect(controller.instance_variable_get(:@nearby_competitions).map(&:id)).to eq [nearby_competition.id]
    end
  end

  describe 'PATCH update edit user' do
    let(:import_request) { create(:import_request) }

    it 'takes over editing' do
      patch "/backend/import_requests/#{import_request.id}",
            params: { import_request: { edit_user_id: login_user.id } }
      import_request.reload
      expect(import_request.edit_user).to eq login_user
      expect(import_request.edited_at).to be_present
    end

    it 'finishes request' do
      patch "/backend/import_requests/#{import_request.id}", params: { import_request: { finished: '1' } }
      expect(import_request.reload.finished_at).to be_present
    end
  end

  context 'when logged in as simple user', login: :user do
    let!(:own_request) { create(:import_request, admin_user: login_user) }
    let!(:foreign_request) { create(:import_request, admin_user: admin) }

    it 'shows own request' do
      get "/backend/import_requests/#{own_request.id}"
      expect(response).to be_successful
    end

    it 'denies foreign request' do
      get "/backend/import_requests/#{foreign_request.id}"
      expect(response).to redirect_to('/')
    end

    it 'denies update of own request' do
      patch "/backend/import_requests/#{own_request.id}", params: { import_request: { finished: '1' } }
      expect(response).to redirect_to('/')
      expect(own_request.reload.finished_at).to be_nil
    end
  end
end
