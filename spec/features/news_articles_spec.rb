# frozen_string_literal: true
require 'rails_helper'

describe 'news features', type: :feature do
  let!(:article) { create(:news_article) }

  it 'shows an overview' do
    visit news_articles_path
    expect(page).to have_content 'Neuigkeiten'
    expect(page).to have_content 'Neuigkeiten von heute'

    visit news_article_path(article)
    expect(page).to have_content 'Neuigkeiten von heute'
    expect(page).to have_content 'Neuigkeiten vom 01.01.2017'
  end
end
