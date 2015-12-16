class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :shortcut, null: false
      t.integer :status, null: false
      t.decimal :latitude, precision: 15, scale: 10
      t.decimal :longitude, precision: 15, scale: 10
      t.string :image
      t.string :state, null: false, default: ""

      t.timestamps null: false
    end
  end
end
