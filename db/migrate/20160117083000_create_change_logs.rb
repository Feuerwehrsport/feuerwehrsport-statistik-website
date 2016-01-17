class CreateChangeLogs < ActiveRecord::Migration
  def change
    create_table :change_logs do |t|
      t.references :admin_user, index: true, foreign_key: true
      t.references :api_user, index: true, foreign_key: true
      t.json :content, null: false

      t.timestamps null: false
    end
  end
end
