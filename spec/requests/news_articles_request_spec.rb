# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NewsArticles' do
  let!(:news_article) { create(:news_article) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/news_articles'
      expect(controller.send(:collection).count).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/news_articles/#{news_article.id}"
      expect(controller.send(:resource)).to eq news_article
    end
  end
end
