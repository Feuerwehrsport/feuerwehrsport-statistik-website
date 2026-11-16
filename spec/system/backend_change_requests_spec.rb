# frozen_string_literal: true

require 'rails_helper'

describe 'backend change requests' do
  it 'shows details and applies a correction after confirmation' do
    person = create(:person)
    other = create(:person, first_name: 'Alfredo')
    ChangeRequest.create!(content: { key: 'person-merge',
                                     data: { person_id: person.id.to_s, correct_person_id: other.id.to_s } })

    sign_in(:sub_admin)
    visit backend_change_requests_path
    find('summary', text: 'Person - Zusammenführen').click
    expect(page).to have_text('Richtige Person')

    accept_confirm(/Fehler wirklich beheben/) { click_on 'Beheben' }
    expect(page).to have_text('Der Fehler wurde behoben.')
    expect(page).to have_text('Keine offenen Meldungen.')
    expect(Person.exists?(person.id)).to be false
  end
end
