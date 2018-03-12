require 'rails_helper'

describe 'registration feature', type: :feature, js: true do
  let!(:competition) { create(:registrations_competition, admin_user: create(:admin_user, role: :sub_admin)) }
  let!(:assessment) { create(:registrations_assessment, competition: competition) }
  let!(:peron) { create(:person) }

  it 'registers person' do
    sign_in :user

    visit registrations_competition_path(competition)
    first(:link, 'Einzelstarter anmelden').click

    within('.modal-content') do
      fill_in 'Schnelleingabe', with: 'Alf Mei'
      expect(find_field('registrations_person[last_name]').value).to eq 'Mei'
      find('.last_name').click
      find('.last_name').click
      expect(find_field('registrations_person[last_name]').value).to eq 'Meier'
      save_review_screenshot
      click_on('Wettkämpfer anlegen')
    end
    within('.datatable') do
      expect(page).to have_content('Alfred')
      expect(page).to have_content('Meier')
      find('.glyphicon-pencil').click
    end
    within('.modal-content') do
      expect(page).to have_content('Alfred Meier')
      save_review_screenshot
      check 'Hakenleitersteigen'
      click_on 'Wettkämpfer speichern'
    end
    within('.datatable') do
      expect(page).to have_content('E')
    end
  end
end
