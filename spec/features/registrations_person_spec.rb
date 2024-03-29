# frozen_string_literal: true

require 'rails_helper'

describe 'registration feature', js: true do
  let!(:competition) do
    create(:registrations_competition, admin_user: create(:admin_user, role: :sub_admin))
  end
  let!(:band) { create(:registrations_band, competition:, person_tags: 'U20') }
  let!(:assessment) { create(:registrations_assessment, band:) }
  let!(:peron) { create(:person) }

  it 'registers person' do
    sign_in :user

    visit registrations_competition_path(competition)
    first(:link, 'Einzelstarter anmelden').click

    fill_in 'Schnelleingabe', with: 'Alf Mei'
    expect(find_field('registrations_person[last_name]').value).to eq 'Mei'
    find('.last_name').click
    find('.last_name').click
    expect(find_field('registrations_person[last_name]').value).to eq 'Meier'
    click_on('Wettkämpfer erstellen')

    within('.datatable') do
      expect(page).to have_content('Alfred')
      expect(page).to have_content('Meier')
      find('.glyphicon-pencil').click
    end
    within('.modal-content') do
      expect(page).to have_content('Alfred Meier')
      check 'Hakenleitersteigen'
      click_on 'Wettkämpfer speichern'
    end
    within('.datatable') do
      expect(page).to have_content('E')
      click_on 'Bearbeiten'
    end

    expect(page).to have_content('Zusätzliche Angaben')
    check 'U20'
    click_on 'Wettkämpfer speichern'

    within('.datatable') do
      expect(page).to have_content('U20')
    end
  end
end
