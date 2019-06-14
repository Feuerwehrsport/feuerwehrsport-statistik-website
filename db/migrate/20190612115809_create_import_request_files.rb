class CreateImportRequestFiles < ActiveRecord::Migration
  def change
    create_table :import_request_files do |t|
      t.references :import_request, index: true, foreign_key: true, null: false
      t.string :file, null: false

      t.timestamps null: false
    end
  end
end
