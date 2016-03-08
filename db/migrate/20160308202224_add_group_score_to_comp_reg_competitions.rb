class AddGroupScoreToCompRegCompetitions < ActiveRecord::Migration
  def change
    add_column :comp_reg_competitions, :group_score, :boolean, null: false, default: false
  end
end
