class CreateGroupScoreCategories < ActiveRecord::Migration
  def change
    create_table :group_score_categories do |t|
      t.references :group_score_type, index: true, null: false, foreign_key: true
      t.references :competition, index: true, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
