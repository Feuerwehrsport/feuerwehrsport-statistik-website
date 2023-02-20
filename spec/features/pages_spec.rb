# frozen_string_literal: true
require 'rails_helper'

describe 'pages features', type: :feature do
  before { page.driver.browser.url_blacklist = ['https://i.ytimg.com', 'youtube'] }

  context 'when dashboard' do
    let!(:score) { create(:score, :double) }
    let!(:news_article) { create(:news_article) }

    it 'shows a lot of information' do
      visit root_path
      expect(page.find('h1')).to have_content 'Feuerwehrsport - die große Auswertung'
      save_review_screenshot
      expect(page.find("h4 a[href='/news_articles/#{news_article.id}']")).to have_content 'Neuigkeiten von heute'
      expect(page).to have_link 'D-Cup - Charlottenthal - 01.05.2017', href: competition_path(score.competition_id)
      expect(page).to have_content 'Super Leistungen vom Jahr 2022'
      expect(page).to have_content 'Fehler in den Daten'
    end
  end

  context 'when legal_notice' do
    it 'shows a contact information' do
      visit impressum_path
      save_review_screenshot
      expect(page).to have_content 'statistik@feuerwehrsport-teammv.de'
    end
  end

  context 'when firesport_overview' do
    it 'shows videos and other information' do
      visit feuerwehrsport_path
      expect(page).to have_content 'Feuerwehrsport - verschiedene Angebote'
      save_review_screenshot
      expect(page).to have_link 'Weitere Informationen', href: wettkampf_manager_path
    end
  end

  context 'when last_competitions_overview' do
    let!(:score) { create(:score, :double) }

    it 'shows list of the last inserted competitions' do
      visit last_competitions_path
      expect(page).to have_content 'Neu eingetragene Wettkämpfe'
      save_review_screenshot
      expect(first('td'))
        .to have_link 'D-Cup - Charlottenthal - 01.05.2017', href: competition_path(score.competition_id)
    end
  end

  context 'when wettkampf_manager' do
    it 'shows other information' do
      visit wettkampf_manager_path
      save_review_screenshot
      expect(page).to have_content 'Hinweise zur Installation'
    end
  end

  context 'when records' do
    it 'shows records' do
      allow(Person).to receive(:find).and_return(build_stubbed(:person))
      allow(Competition).to receive(:find).and_return(build_stubbed(:competition))
      allow(Team).to receive(:find).and_return(build_stubbed(:team))
      allow(Nation).to receive(:find_by).and_return(build_stubbed(:nation))

      visit records_path
      expect(page).to have_content 'Weltrekorde - Männer'
      save_review_screenshot
      expect(page).to have_content 'Deutsche Rekorde - Männer'
      expect(page).to have_content 'Deutsche Rekorde - Frauen'
    end
  end

  context 'when best_of' do
    let!(:score) { create(:score, :double, person: create(:person, :female)) }

    it 'shows best_of' do
      visit best_of_path
      expect(page).to have_content 'Die 100 schnellsten Zeiten'
      save_review_screenshot
      expect(page).to have_content 'Johanna Meyer'
      expect(page).to have_content '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'
    end
  end
end
