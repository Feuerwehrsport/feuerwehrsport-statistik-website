# frozen_string_literal: true

class RemovePdf2Table < ActiveRecord::Migration[5.2]
  def change
    drop_table :pdf2_table_entries
  end
end
