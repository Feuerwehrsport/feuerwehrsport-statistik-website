# frozen_string_literal: true

class RemoveM3DeliverySettings < ActiveRecord::Migration[5.2]
  def change
    drop_table :m3_delivery_settings
  end
end
