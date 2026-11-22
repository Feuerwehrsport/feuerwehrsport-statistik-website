# frozen_string_literal: true

require 'rails_helper'

# filter form of the backend index pages (bootstrap dropdown)
describe 'backend filters' do
  before do
    create(:competition)
    sign_in(:admin)
  end

  it 'opens the filter dropdown' do
    visit backend_competitions_path
    expect(page).to have_css('.filters-form', visible: :hidden)
    click_on 'Filter'
    within('.filters-form') { expect(page).to have_button('Suchen') }
  end
end
