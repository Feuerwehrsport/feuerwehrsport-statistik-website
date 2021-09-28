# frozen_string_literal: true

class AddPortAndProtocolToM3Website < ActiveRecord::Migration[4.2]
  def change
    add_column :m3_websites, :port, :int, default: 80, null: false
    add_column :m3_websites, :protocol, :string, default: 'http', null: false
  end
end
