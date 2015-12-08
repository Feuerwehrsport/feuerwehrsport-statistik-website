class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email_address
      t.string :ip_address_hash
      t.string :user_agent_hash
      t.string :user_agent_meta

      t.timestamps null: false
    end
  end
end
