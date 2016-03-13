class AddRegistrationOrderToCompRegPeople < ActiveRecord::Migration
  def change
    add_column :comp_reg_people, :registration_order, :integer, default: 0, null: false
  end
end
