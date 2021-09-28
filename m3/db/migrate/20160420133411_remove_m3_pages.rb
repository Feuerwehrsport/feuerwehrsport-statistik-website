# frozen_string_literal: true

class RemoveM3Pages < ActiveRecord::Migration[4.2]
  def change
    drop_table :m3_page_components
    drop_table :m3_pages
    drop_table :content_elements
    drop_table :content_lists
  end
end
