# frozen_string_literal: true

# results of an import request that were imported already ("<result_index>-<gender>")
class AddImportedResultKeysToImportRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :import_requests, :imported_result_keys, :string, array: true, default: [], null: false
  end
end
