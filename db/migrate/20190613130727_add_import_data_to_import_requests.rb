class AddImportDataToImportRequests < ActiveRecord::Migration
  def change
    add_column :import_requests, :import_data, :json
  end
end
