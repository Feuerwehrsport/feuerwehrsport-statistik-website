# frozen_string_literal: true

require 'rails_helper'

describe 'registration feature', js: true do
  let!(:competition) do
    create(:registrations_competition, admin_user: create(:admin_user, role: :sub_admin), team_tags: 'Kreiswertung')
  end
  let!(:assessment) { create(:registrations_assessment, :la, competition: competition) }
  let!(:team) { create(:team) }

  it 'registers team' do
    sign_in :user
    visit registrations_competition_path(competition)

    first(:link, 'Mannschaft anmelden').click

    fill_in 'Schnelleingabe', with: 'FF arin'
    expect(find_field('registrations_team[name]').value).to eq 'FF arin'
    expect(find_field('registrations_team[shortcut]').value).to eq 'arin'
    find('.name').click
    find('.name').click
    expect(find_field('registrations_team[name]').value).to eq 'FF Warin'
    expect(find_field('registrations_team[shortcut]').value).to eq 'Warin'
    save_review_screenshot
    expect do
      select 'männlich', from: 'Geschlecht'
      click_on('Mannschaft erstellen')

      fill_in 'Mannschaftsleiter', with: 'Max Mustermann'
      fill_in 'Straße und Hausnummer', with: 'Musterstraße 123'
      fill_in 'Postleitzahl', with: '98765'
      fill_in 'Ort', with: 'Musterstadt'
      fill_in 'Telefonnummer', with: '+1233/234432'
      fill_in 'E-Mail-Adresse', with: 'foo@bar.de'
      save_review_screenshot
      check 'Löschangriff nass'
      click_on 'Speichern'
    end.to change(Registrations::Team, :count).by(1)
    expect(Registrations::Team.last.team_id).to eq team.id

    expect(page).to have_content('Max Mustermann')
    expect(page).to have_content('Musterstraße 123')
    expect(page).to have_content('98765')
    expect(page).to have_content('Musterstadt')
    expect(page).to have_content('+1233/234432')
    expect(page).to have_content('foo@bar.de')

    click_on 'Bearbeiten'
    check 'Kreiswertung'
    click_on 'Speichern'

    expect(page).to have_content('männlich, Kreiswertung')
  end
end
