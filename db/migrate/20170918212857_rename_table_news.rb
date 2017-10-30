class RenameTableNews < ActiveRecord::Migration
  def change
    rename_table :news, :news_articles
  end
end
