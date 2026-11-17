# frozen_string_literal: true

require 'rails_helper'

# delete links and confirmations with Turbo (data-turbo-method, data-turbo-confirm)
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

  it 'shows validation errors of a Turbo form submission (status 422)' do
    place = create(:place)
    visit edit_backend_place_path(place)
    fill_in 'Name', with: ''
    click_on 'Speichern'
    expect(page).to have_text('Ein Problem ist aufgetreten')
    expect(page).to have_css('.is-invalid')

    fill_in 'Name', with: 'Cottbus'
    click_on 'Speichern'
    expect(page).to have_current_path(backend_place_path(place))
    expect(place.reload.name).to eq 'Cottbus'
  end

  it 'saves the content of the rich text editor with a Turbo form submission' do
    competition = create(:competition)
    visit edit_backend_competition_path(competition)
    expect(page).to have_css('.cke_editable, .cke_wysiwyg_frame')
    page.execute_script("Object.values(CKEDITOR.instances)[0].setData('<p>Hinweis aus dem Editor</p>')")
    click_on 'Speichern'
    expect(page).to have_current_path(backend_competition_path(competition))
    expect(competition.reload.hint_content).to include('Hinweis aus dem Editor')
  end
end
