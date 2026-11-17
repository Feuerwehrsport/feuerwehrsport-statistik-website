# frozen_string_literal: true

require 'rails_helper'

describe 'backend forms' do
  it 'chooses associated records in the search modal and loads associated tables' do
    group_score = create(:group_score)
    create(:person, first_name: 'Alfred')
    other = create(:person, first_name: 'Zacharias', last_name: 'Neumann')

    sign_in(:admin)
    visit new_backend_person_participation_path

    within('.row.mb-3', text: 'Person', match: :first) do
      click_on 'Auswählen'
    end
    within('.modal.show') do
      find('.as-search').fill_in(with: 'Neumann')
      find('.as-selectable', text: 'Neumann').click
    end
    expect(page).to have_no_css('.modal.show')
    within('.row.mb-3', text: 'Person', match: :first) { expect(page).to have_text('Zacharias Neumann') }

    within('.row.mb-3', text: 'Mannschaftszeit', match: :first) { click_on 'Auswählen' }
    within('.modal.show') { find('.as-selectable', match: :first).click }
    fill_in 'Position', with: '2'
    click_on 'Speichern'

    expect(PersonParticipation.last).to have_attributes(person_id: other.id, group_score_id: group_score.id,
                                                        position: 2)

    # show page of the person loads the tables of associated records
    visit backend_person_path(other)
    expect(page).to have_css('[data-controller="remote-index-table"] table')
  end
end
