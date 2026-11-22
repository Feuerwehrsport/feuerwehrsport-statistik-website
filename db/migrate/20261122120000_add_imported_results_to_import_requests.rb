# frozen_string_literal: true

# records created by the import of each result of an import request (to undo the import)
class AddImportedResultsToImportRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :import_requests, :imported_results, :jsonb, default: {}, null: false
  end
end
