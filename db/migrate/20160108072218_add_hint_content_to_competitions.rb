class AddHintContentToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :hint_content, :text, null: false, default: ""
  end
end
