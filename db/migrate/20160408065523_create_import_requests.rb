class CreateImportRequests < ActiveRecord::Migration
  def change
    create_table :import_requests do |t|
      t.string :file
      t.string :url
      t.date :date
      t.references :place, index: true
      t.references :event, index: true
      t.text :description
      t.references :admin_user, index: true
      t.references :edit_user, index: true
      t.datetime :edited_at
      t.datetime :finished_at

      t.timestamps null: false
    end
  end
end
