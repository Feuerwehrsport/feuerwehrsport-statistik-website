class AddUserToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :creator_id, :integer
    add_column :appointments, :creator_type, :string
  end
end
