class NewsPublishedAtToDate < ActiveRecord::Migration
  def change
    change_column :news_articles, :published_at, :date
  end
end
