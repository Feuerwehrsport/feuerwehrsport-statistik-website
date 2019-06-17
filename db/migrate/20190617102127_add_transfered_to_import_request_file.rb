class AddTransferedToImportRequestFile < ActiveRecord::Migration[5.0]
  def change
    add_column :import_request_files, :transfered, :boolean, default: false, null: false
  end
end
