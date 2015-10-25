class CreateGroupScoreTypes < ActiveRecord::Migration
  def change
    create_table :group_score_types do |t|
      t.string :discipline, null: false
      t.string :name, null: false
      t.boolean :regular, null: false, default: false

      t.timestamps null: false
    end
  end
end
