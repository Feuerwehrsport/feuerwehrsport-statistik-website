class RemovePublishedAtFromAppointments < ActiveRecord::Migration
  def change
    remove_column :appointments, :published_at, :string
  end
end
