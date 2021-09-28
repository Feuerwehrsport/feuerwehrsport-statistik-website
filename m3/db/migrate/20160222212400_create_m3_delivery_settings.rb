# frozen_string_literal: true

class CreateM3DeliverySettings < ActiveRecord::Migration[4.2]
  def change
    create_table :m3_delivery_settings do |t|
      t.references :website, index: true, null: false
      t.string :delivery_method, null: false, default: 'file'
      t.string :address
      t.integer :port
      t.string :domain
      t.string :user_name
      t.string :password
      t.string :authentication
      t.boolean :enable_starttls_auto
      t.boolean :tls
      t.string :openssl_verify_mode
      t.string :location
      t.string :arguments
      t.string :from_address
      t.string :from_name
      t.string :reply_to_address
      t.string :reply_to_name

      t.timestamps null: false
    end
    add_foreign_key :m3_delivery_settings, :m3_websites, column: :website_id
  end
end
