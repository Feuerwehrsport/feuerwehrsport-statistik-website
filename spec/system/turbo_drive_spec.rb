# frozen_string_literal: true

require 'rails_helper'

describe 'Turbo Drive' do
  before { page.driver.browser.url_blacklist = [/openstreetmap/] }

  # set on the page; it survives Turbo visits, a full page load removes it
  def mark_page
    page.execute_script('window.turboMarker = true')
  end

  def same_page_load?
    page.evaluate_script('window.turboMarker === true')
  end

  it 'navigates without full page loads and initialises tables, maps, charts and dialogs' do
    place = create(:place)
    create_list(:competition, 2, place:)

    visit places_path
    mark_page
    expect(page).to have_css('#places-map.leaflet-container')

    find("a[href='#{place_path(place)}']", match: :first).click
    expect(page).to have_current_path(place_path(place))
    expect(page).to have_css('.dt-container', count: 1)
    expect(page).to have_css('.chart-box canvas[style*="box-sizing"]')

    page.go_back
    expect(page).to have_current_path(places_path)
    expect(page).to have_css('#places-map.leaflet-container')
    expect(page).to have_css('.dt-container', count: 1)
    page.go_forward
    expect(page).to have_current_path(place_path(place))
    expect(page).to have_css('.dt-container', count: 1)

    within('.navbar') { click_on 'Personen' }
    click_on 'Person hinzufügen'
    expect(page).to have_css('dialog[open]', text: 'Anmelden')
    expect(same_page_load?).to be true
  end

  it 'reloads the page when switching to the backend bundle' do
    sign_in(:admin)
    visit root_path
    mark_page
    page.execute_script("Turbo.visit('/backend')")
    expect(page).to have_current_path(backend_root_path)
    expect(page).to have_text('Fehlermeldungen bearbeiten')
    expect(same_page_load?).to be false
  end
end
