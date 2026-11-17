# frozen_string_literal: true

require 'rails_helper'

# data-method and data-confirm (app/javascript/rails_actions.js, replacement for jquery_ujs)
describe 'backend actions' do
  let!(:link) { create(:link) }

  before { sign_in(:admin) }

  it 'deletes after confirmation with the delete link' do
    visit backend_link_path(link)
    accept_confirm('Diesen Eintrag wirklich löschen?') do
      within('.page-head-actions') { click_on 'Löschen' }
    end
    expect(page).to have_current_path(backend_links_path)
    expect(Link.exists?(link.id)).to be false
  end

  it 'keeps the record when the confirmation is dismissed' do
    visit backend_link_path(link)
    dismiss_confirm('Diesen Eintrag wirklich löschen?') do
      within('.page-head-actions') { click_on 'Löschen' }
    end
    expect(page).to have_current_path(backend_link_path(link))
    expect(Link.exists?(link.id)).to be true
  end

  it 'logs out with the delete link of the dashboard' do
    visit backend_root_path
    accept_confirm('Möchtest du dich abmelden?') { click_on 'Abmelden' }
    expect(page).to have_current_path(new_session_path)
    expect(page).to have_button('Anmelden')
  end
end
