# frozen_string_literal: true

class RenameM3AssetsToAssets < ActiveRecord::Migration[8.1]
  def change
    rename_table :m3_assets, :assets
  end
end
