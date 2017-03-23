class AddTeamNameToCompRegPeople < ActiveRecord::Migration
  def change
    add_column :comp_reg_people, :team_name, :string
  end
end
