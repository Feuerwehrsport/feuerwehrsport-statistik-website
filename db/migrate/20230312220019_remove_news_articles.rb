# frozen_string_literal: true

class RemoveNewsArticles < ActiveRecord::Migration[7.0]
  def change
    drop_table :news_articles
  end
end
