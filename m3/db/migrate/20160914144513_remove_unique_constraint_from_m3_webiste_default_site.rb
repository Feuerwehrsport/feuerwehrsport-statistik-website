# frozen_string_literal: true

class RemoveUniqueConstraintFromM3WebisteDefaultSite < ActiveRecord::Migration[4.2]
  def change
    remove_index :m3_websites, :default_site
  end
end
