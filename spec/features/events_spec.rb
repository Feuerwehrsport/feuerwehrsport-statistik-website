require 'rails_helper'

describe 'events features', type: :feature, js: true do
  let(:event) { create(:event) }

  context 'when index' do
    it 'shows an overview' do
      create_list(:event, 13).each { |event| create(:competition, event: event) }

      visit events_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on 'Nächste', match: :first
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück', match: :first
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end
  end

  context 'when  show' do
    it 'shows an competitions overview' do
      create_list(:competition, 13, event: event)

      visit event_path(event)
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on('Nächste')
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end
  end
end
