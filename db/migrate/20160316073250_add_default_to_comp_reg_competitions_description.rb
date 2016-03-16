class AddDefaultToCompRegCompetitionsDescription < ActiveRecord::Migration
  def change
    change_column :comp_reg_competitions, :description, :text, null: false, default: ""
  end
end
