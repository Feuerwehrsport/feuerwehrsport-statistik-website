# frozen_string_literal: true

# competition the results of an import request are imported into (step 1 of the import)
class AddCompetitionToImportRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :import_requests, :competition, type: :integer, foreign_key: { on_delete: :nullify }
  end
end
