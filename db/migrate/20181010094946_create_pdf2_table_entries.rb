class CreatePdf2TableEntries < ActiveRecord::Migration
  def change
    create_table :pdf2_table_entries do |t|
      t.string :pdf, null: false
      t.string :ods
      t.string :csv
      t.text :csv_to_copy
      t.text :log
      t.references :api_user, index: true, foreign_key: true
      t.references :admin_user, index: true, foreign_key: true
      t.datetime :locked_at
      t.datetime :finished_at
      t.boolean :success

      t.timestamps null: false
    end
  end
end
