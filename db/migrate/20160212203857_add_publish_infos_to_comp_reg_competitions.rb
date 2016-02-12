class AddPublishInfosToCompRegCompetitions < ActiveRecord::Migration
  def change
    add_column :comp_reg_competitions, :slug, :string
    add_column :comp_reg_competitions, :published, :boolean, null: false, default: false
    add_index :comp_reg_competitions, :slug, unique: true
  end
end
