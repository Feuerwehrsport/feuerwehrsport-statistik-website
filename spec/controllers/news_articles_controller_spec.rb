# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsArticlesController do
  let!(:news_article) { create(:news_article) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(controller.send(:collection).count).to eq 1
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get :show, params: { id: news_article.id }
      expect(controller.send(:resource)).to eq news_article
    end
  end
end
