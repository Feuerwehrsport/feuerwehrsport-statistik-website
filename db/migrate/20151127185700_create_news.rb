class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.references :admin_user, index: true, foreign_key: true
      t.string :content
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
