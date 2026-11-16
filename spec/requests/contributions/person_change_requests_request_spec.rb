# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::PersonChangeRequests' do
  let!(:person) { create(:person) }
  let!(:other_person) { create(:person, first_name: 'Alfredo') }
  let(:path) { "/contributions/people/#{person.id}/change_request" }

  context 'when logged in', login: :api do
    it 'shows the steps' do
      get "#{path}/new"
      expect(response.body).to include('Was ist falsch?', 'kind=wrong', 'kind=change-nation', 'kind=other')

      get "#{path}/new", params: { kind: 'wrong' }
      expect(response.body).to include('kind=merge', 'kind=correction')
    end

    it 'searches people for merge without the person itself' do
      get "#{path}/new", params: { kind: 'merge', q: 'Meier' }
      expect(response.body).to include('Meier, Alfredo')
      expect(response.body).not_to include("value=\"#{person.id}\"")
    end

    it 'creates a change request with mail and change log' do
      expect do
        post path, params: { kind: 'merge', correct_person_id: other_person.id }
      end.to change(ChangeRequest, :count).by(1).and have_enqueued_mail(ChangeRequestMailer, :new_notification)

      expect(ChangeRequest.last).to have_attributes(
        content: { key: 'person-merge', data: { person_id: person.id.to_s, correct_person_id: other_person.id.to_s } },
        api_user: login_user,
      )
      expect(ChangeLog.last).to have_attributes(action: 'create-changerequest', api_user: login_user)
      expect(response.body).to include('Der Fehlerbericht wurde gespeichert')
    end

    it 'does not merge a person with itself' do
      expect { post path, params: { kind: 'merge', correct_person_id: person.id } }.not_to change(ChangeRequest, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Bitte die richtige Person auswählen.')
    end

    it 'rejects unknown kinds' do
      expect { post path, params: { kind: 'destroy' } }.not_to change(ChangeRequest, :count)
      expect(response.body).to include('Bitte wählen Sie das Problem aus.')
    end
  end

  it 'redirects to the login without login' do
    get "#{path}/new"
    expect(response).to redirect_to(%r{/contributions/login/new\?return_to=})
  end
end
