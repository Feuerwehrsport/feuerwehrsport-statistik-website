class DropRegistrationsMail < ActiveRecord::Migration
  def change
    drop_table :registrations_competitions_mails
  end
end
