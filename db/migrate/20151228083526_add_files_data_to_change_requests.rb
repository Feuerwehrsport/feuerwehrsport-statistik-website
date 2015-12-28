class AddFilesDataToChangeRequests < ActiveRecord::Migration
  def change
    add_column :change_requests, :files_data, :json, default: "{}", null: false
  end
end
