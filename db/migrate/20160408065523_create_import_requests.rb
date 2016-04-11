class CreateImportRequests < ActiveRecord::Migration
  def change
    create_table :import_requests do |t|
      t.string :file
      t.date :date
      t.references :place, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.text :description
      t.references :admin_user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
