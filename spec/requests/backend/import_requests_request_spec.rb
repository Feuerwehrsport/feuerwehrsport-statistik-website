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

    it 'shows the import information without the import steps' do
      get "/backend/import_requests/#{import_request.id}"
      expect(response).to be_successful
      expect(response.body).to include('import-request-info', 'Bearbeitung übernehmen')
      expect(response.body).not_to include('import-step-competition')
    end

    context 'when editing' do
      before do
        import_request.update!(edit_user_id: login_user.id)
        result = { discipline: 'hb', gender: 'male', name: 'HB', rows: [%w[time], %w[1]] }
        import_request.update_column(:import_data, { results: [result] })
      end

      it 'asks for the competition with suggestions around the date' do
        get "/backend/import_requests/#{import_request.id}"
        expect(response.body).to include('1. Wettkampf zuordnen', 'competition-suggestions', 'Nah dran',
                                         'Neuen Wettkampf anlegen', "import_request_id=#{import_request.id}")
        expect(response.body).not_to include('Weit weg', 'import-step-results', 'result_index=0')
      end

      it 'stores the competition and shows the second step' do
        patch "/backend/import_requests/#{import_request.id}/assign_competition",
              params: { competition_id: nearby_competition.id }
        expect(response).to redirect_to("/backend/import_requests/#{import_request.id}")
        expect(import_request.reload.competition).to eq nearby_competition

        get "/backend/import_requests/#{import_request.id}"
        expect(response.body).to include(
          'import-step-results', 'Anderen Wettkampf wählen',
          "import_request_id=#{import_request.id}&amp;result_index=0",
          "/backend/import_request_files/#{import_request.import_request_files.first.id}/transfer"
        )
        expect(response.body).not_to include('competition-suggestions')

        patch "/backend/import_requests/#{import_request.id}/assign_competition", params: { competition_id: '' }
        expect(import_request.reload.competition).to be_nil
      end

      it 'offers both genders for results without gender' do
        result = { discipline: 'la', gender: 'indifferent', name: 'Wanderpokal', rows: [%w[time], %w[1]] }
        import_request.update!(competition: nearby_competition)
        import_request.update_column(:import_data, { results: [result] })
        get "/backend/import_requests/#{import_request.id}"
        expect(response.body).to include('la 1 Wanderpokal', 'discipline=la&amp;gender=female',
                                         'discipline=la&amp;gender=male')
        expect(response.body).not_to include('gender=indifferent')
      end

      it 'marks imported results' do
        import_request.update!(competition: nearby_competition, imported_result_keys: ['0-male'])
        get "/backend/import_requests/#{import_request.id}"
        expect(response.body).to include('imported-result', 'bi-check-circle-fill')
      end

      it 'transfers all pdfs with the guessed disciplines' do
        import_request.update!(competition: nearby_competition)
        import_request.import_request_files.create!(
          file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/testfile.pdf'), 'application/pdf'),
        )
        get "/backend/import_requests/#{import_request.id}"
        expect(response.body).to include('Alle 2 PDFs übertragen')

        expect do
          patch "/backend/import_requests/#{import_request.id}/transfer_files"
        end.to change(CompetitionFile, :count).by(2)
        expect(CompetitionFile.distinct.pluck(:competition_id)).to eq [nearby_competition.id]
        expect(import_request.import_request_files.reload.map(&:transfered)).to all(be true)
      end

      it 'creates the competition for the import request' do
        post '/backend/imports/competitions', params: {
          import_request_id: import_request.id, return_to: "/backend/import_requests/#{import_request.id}",
          competition: { name: 'Neu', date: '2017-05-03', place_id: place.id, event_id: event.id }
        }
        expect(import_request.reload.competition).to have_attributes(name: 'Neu')
      end

      it 'transfers a file to the competition' do
        file = import_request.import_request_files.first
        expect do
          patch "/backend/import_request_files/#{file.id}/transfer",
                params: { competition_id: nearby_competition.id, keys: %w[hb_male unknown] }
        end.to change(CompetitionFile, :count).by(1)
        expect(CompetitionFile.last).to have_attributes(competition_id: nearby_competition.id, keys_string: 'hb_male')
        expect(file.reload.transfered).to be true
      end
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

    it 'lists only own requests' do
      own_request.update!(description: 'Mein eigener Wettkampf')
      foreign_request.update!(description: 'Fremder Wettkampf')
      get '/backend/import_requests'
      expect(response).to be_successful
      expect(response.body).to include('Mein eigener Wettkampf')
      expect(response.body).not_to include('Fremder Wettkampf')
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
