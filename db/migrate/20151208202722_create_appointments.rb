class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.date :dated_at, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.references :place, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.string :disciplines, null: false
      t.string :published_at

      t.timestamps null: false
    end
  end
end
