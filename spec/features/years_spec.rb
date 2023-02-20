# frozen_string_literal: true
require 'rails_helper'

describe 'years features' do
  (2000..2017).each do |year|
    let!(:"competition_#{year}") { create(:competition, date: Date.new(year, 1, 1)) }
    let!(:competitions) { create_list(:competition, 15, date: Date.new(2012, 1, 1)) }
    let!(:score) { create(:score, :double, competition: competitions.first) }
    let!(:group_score) { create(:score, :double, competition: competitions.first) }
  end

  it 'visit all functions' do
    visit years_path
    expect(page).to have_content '1 bis 10 von 18 Einträgen'
    save_review_screenshot
    click_on 'Nächste'
    expect(page).to have_content '11 bis 18 von 18 Einträgen'
    click_on 'Zurück'

    click_on '2012'
    expect(page).to have_content '1 bis 10 von 16 Einträgen'
    save_review_screenshot
    expect(page).to have_current_path year_path(2012)
    click_on 'Nächste'
    expect(page).to have_content '11 bis 16 von 16 Einträgen'

    click_on 'Bestzeiten des Jahres', match: :first
    expect(page).to have_content 'Bestzeiten des Jahres 2012'
    save_review_screenshot
    expect(page).to have_content '1 bis 1 von 1 Einträgen'
    expect(page).to have_current_path best_scores_year_path(2012)

    click_on 'Bestleistungen des Jahres'
    expect(page).to have_content 'Bestleistungen des Jahres 2012'
    save_review_screenshot
    expect(page).to have_content '1 bis 1 von 1 Einträgen'
    expect(page).to have_current_path best_performance_year_path(2012)
    expect(page).to have_content 'Punkte'
  end
end
