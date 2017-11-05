require 'rails_helper'

describe 'create competition', type: :feature, js: true do
  pending 'registers' do
    sign_in :user

    click_on 'Anmelden'
    click_on 'Wettkampfanmeldungen'
    click_on 'Neuen Wettkampf anlegen'
    expect(page).to have_content('Vorlage für Wettkämpf wählen')

    within('.template:nth-child(5)') do
      click_on 'Als Vorlage wählen'
    end

    expect(find_field('comp_reg_competition_name').value).to eq 'Deutschland-Cup'
    fill_in 'Datum', with: '29.02.2020'
    fill_in 'Ort', with: 'Ostseebad Nienhagen'
    click_on 'Wettkampf anlegen'

    expect(page).to have_content('Wettkampf ist noch nicht öffentlich')
    expect(page).to have_content('29.02.2020')

    click_on 'Veröffentlichen'
    check 'Veröffentlichen'
    click_on 'Wettkampf speichern'

    expect(page).not_to have_content('Wettkampf ist noch nicht öffentlich')
    expect(page).to have_content('Wettkampf bearbeiten')

    first(:link, 'Mannschaft anmelden').click
    expect(page).to have_content('Wettkampfanmeldung')
    expect(page).to have_content('Daten der Mannschaft')
    click_on 'Deutschland-Cup - 29.02.2020'

    first(:link, 'Wettkämpfer anmelden').click
    expect(page).to have_content('Schnelleingabe')
    expect(page).to have_content('Zusätzliche Angaben')
    find('.close').click

    sign_out

    sign_in :user, :second
    click_on 'Termine'
    click_on 'Online-Anmeldungen'
    click_on 'Deutschland-Cup'

    first(:link, 'Mannschaft anmelden').click
    fill_in 'Name', with: 'Team Mecklenburg-Vorpommern'
    fill_in 'Abkürzung', with: 'Team MV'
    select 'männlich', from: 'Geschlecht'

    fill_in 'Mannschaftsleiter', with: 'Max Mustermann'
    fill_in 'Straße und Hausnummer', with: 'Musterstraße 123'
    fill_in 'Postleitzahl', with: '98765'
    fill_in 'Ort', with: 'Musterstadt'
    fill_in 'Telefonnummer', with: '+1233/234432'
    fill_in 'E-Mail-Adresse', with: 'foo@bar.de'
    click_on 'Weiter'

    within '.team-assessment-participation:first-child' do
      check 'Teilnahme'
    end
    click_on 'Mannschaft anlegen'

    expect(page).to have_content('Max Mustermann')
    expect(page).to have_content('Musterstraße 123')
    expect(page).to have_content('98765')
    expect(page).to have_content('Musterstadt')
    expect(page).to have_content('+1233/234432')
    expect(page).to have_content('foo@bar.de')

    first(:link, 'Wettkämpfer hinzufügen').click
    fill_in 'Schnelleingabe', with: 'Rico Reich'
    expect(find_field('comp_reg_person[last_name]').value).to eq 'Reich'
    find('.last_name').click
    expect(find_field('comp_reg_person[last_name]').value).to eq 'Reichel'
    click_on('Wettkämpfer anlegen')
    within('.people-sortable-table') do
      expect(page).to have_content('Rico')
      expect(page).to have_content('Reichel')
    end
    click_on 'Deutschland-Cup'
    sign_out
  end
end
