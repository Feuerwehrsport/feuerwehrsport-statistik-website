class CreateIpoRegistrations < ActiveRecord::Migration
  def change
    create_table :ipo_registrations do |t|
      t.string :team_name, null: false, limit: 200
      t.string :name, null: false, limit: 200
      t.string :locality, null: false, limit: 200
      t.string :phone_number, null: false, limit: 200
      t.string :email_address, null: false, limit: 200
      t.boolean :youth_team, null: false, default: false
      t.boolean :female_team, null: false, default: false
      t.boolean :male_team, null: false, default: false
      t.boolean :terms_of_service, null: false, default: false

      t.timestamps null: false
    end
  end
end
