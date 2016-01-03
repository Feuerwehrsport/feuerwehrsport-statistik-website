require 'rails_helper'

describe "years features", type: :feature, js: true, driver: :webkit do
  context "index" do
    it "shows an overview" do
      visit years_path
      expect(page).to have_content '1 bis 10 von 28 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 28 Einträgen'
    end
  end

  context "show" do
    it "shows an competitions overview" do
      visit year_path(id: 2015)
      expect(page).to have_content '1 bis 10 von 100 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 100 Einträgen'
    end
  end

  context "best_scores" do
    it "shows the best scores" do
      visit best_scores_year_path(id: 2015)
      expect(page).to have_content 'Bestzeiten des Jahres 2015'
      expect(page).to have_content '1 bis 10 von 93 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 93 Einträgen'
    end
  end

  context "best_performance" do
    it "shows the best performance" do
      visit best_performance_year_path(id: 2015)
      expect(page).to have_content 'Bestleistungen des Jahres 2015'
      expect(page).to have_content 'Punkte'
      expect(page).to have_content '1 bis 10 von 93 Einträgen'
      click_on("Nächste")
      expect(page).to have_content '11 bis 20 von 93 Einträgen'
    end
  end
end