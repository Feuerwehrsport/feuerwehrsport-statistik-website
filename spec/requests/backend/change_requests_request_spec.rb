# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::ChangeRequests' do
  def change_request(key, data, files: [])
    ChangeRequest.create!(content: { key:, data: }, files:)
  end

  def apply(change_request, params = {})
    post "/backend/change_requests/#{change_request.id}/apply", params:
  end

  it 'is not accessible for users', login: :user do
    get '/backend/change_requests'
    expect(response).to redirect_to('/')
  end

  context 'when sub admin', login: :sub_admin do
    let!(:person) { create(:person) }
    let!(:other_person) { create(:person, first_name: 'Alfredo') }
    let!(:team) { create(:team) }
    let!(:other_team) { create(:team, name: 'FF Anders', shortcut: 'Anders') }
    let!(:competition) { create(:competition) }

    it 'shows all kinds of open change requests' do
      change_request('person-merge', { person_id: person.id.to_s, correct_person_id: other_person.id.to_s })
      change_request('team-correction', { team_id: team.id.to_s, team: { name: 'FF Neu', shortcut: 'Neu' } })
      change_request('competition-add-hint', { competition_id: competition.id.to_s, hint: 'Regen' })
      change_request('report-link', { link_id: '999' })
      change_request('unknown-key', { foo: 'bar' })
      ChangeRequest.create!(content: { key: 'person-other', data: {} }, done_at: Time.current)

      get '/backend/change_requests'
      expect(response).to be_successful
      expect(response.body).to include('Person - Zusammenführen', 'Alfredo', 'Mannschaft - Korrektur', 'FF Neu',
                                       'Regen', 'Nicht mehr vorhanden (ID 999)', 'unknown-key')
      expect(response.body).not_to include('Person - Freitext')
    end

    it 'marks as done' do
      request = change_request('person-other', { person_id: person.id.to_s, description: 'x' })
      patch "/backend/change_requests/#{request.id}/done"
      expect(request.reload.done_at).to be_present
    end

    it 'corrects a person with change log' do
      request = change_request('person-correction', { person_id: person.id.to_s,
                                                      person: { first_name: 'Neu', last_name: 'Name' } })
      apply(request)
      expect(person.reload).to have_attributes(first_name: 'Neu', last_name: 'Name')
      expect(request.reload.done_at).to be_present
      expect(ChangeLog.last).to have_attributes(action: 'update-person:name', admin_user: login_user)
      expect(ChangeLog.last.content[:before_hash]).to include(first_name: 'Alfred')
    end

    it 'changes the nation' do
      ungarn = create(:nation, :ungarn)
      apply(change_request('person-change-nation', { person_id: person.id.to_s, nation_id: ungarn.id.to_s }))
      expect(person.reload.nation_id).to eq ungarn.id
    end

    it 'merges people always' do
      apply(change_request('person-merge', { person_id: person.id.to_s, correct_person_id: other_person.id.to_s }),
            always: 1)
      expect(Person.exists?(person.id)).to be false
      expect(EntityMerge.last).to have_attributes(source_id: person.id, target: other_person)
      expect(PersonSpelling.count).to eq 1
      expect(ChangeLog.last).to have_attributes(action: 'merge')
    end

    it 'merges teams' do
      apply(change_request('team-merge', { team_id: other_team.id.to_s, correct_team_id: team.id.to_s }))
      expect(Team.exists?(other_team.id)).to be false
      expect(TeamSpelling.count).to eq 0
    end

    it 'corrects a team' do
      apply(change_request('team-correction', { team_id: team.id.to_s,
                                                team: { name: 'FF Neu', shortcut: 'Neu', status: 'team' } }))
      expect(team.reload).to have_attributes(name: 'FF Neu', shortcut: 'Neu', status: 'team')
    end

    it 'sets the competition name, optionally edited' do
      apply(change_request('competition-change-name', { competition_id: competition.id.to_s, name: 'Vorschlag' }),
            name: 'Bearbeitet')
      expect(competition.reload.name).to eq 'Bearbeitet'
      expect(ChangeLog.last).to have_attributes(action: 'update-competition:name')
    end

    it 'deletes a reported link' do
      link = Link.create!(linkable: team, label: 'Seite', url: 'https://example.com')
      apply(change_request('report-link', { link_id: link.id.to_s }))
      expect(Link.exists?(link.id)).to be false
      expect(ChangeLog.last).to have_attributes(action: 'destroy-link')
    end

    context 'with logo files' do
      # ChangeRequest#files= only takes uploads of a real request
      def upload(name, type)
        ActionDispatch::Http::UploadedFile.new(tempfile: file_fixture(name).open, filename: name, type:)
      end

      let(:png) { upload('testfile.png', 'image/png') }
      let(:pdf) { upload('testfile.pdf', 'application/pdf') }
      let(:request) { change_request('team-logo', { team_id: team.id.to_s }, files: [pdf, png]) }

      it 'shows images inline and other files as download' do
        get "/backend/change_requests/#{request.id}/files/1"
        expect(response.headers['Content-Type']).to eq 'image/png'
        expect(response.headers['Content-Disposition']).to start_with('inline')

        get "/backend/change_requests/#{request.id}/files/0"
        expect(response.headers['Content-Type']).to eq 'application/octet-stream'
        expect(response.headers['Content-Disposition']).to start_with('attachment')
      end

      it 'sets the selected file as logo' do
        apply(request, file_index: 1)
        expect(team.reload.image).to be_present
        expect(ChangeLog.last).to have_attributes(action: 'update-team:image')
      end
    end

    it 'keeps the change request open when the record is missing' do
      request = change_request('person-correction', { person_id: '0', person: { first_name: 'A', last_name: 'B' } })
      apply(request)
      expect(request.reload.done_at).to be_nil
      expect(flash[:alert]).to start_with('Konnte nicht behoben werden')
    end

    it 'has no automatic fix for free text' do
      request = change_request('person-other', { person_id: person.id.to_s, description: 'x' })
      apply(request)
      expect(request.reload.done_at).to be_nil
    end
  end
end
