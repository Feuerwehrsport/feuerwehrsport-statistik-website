class AddBestToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :best_scores, :jsonb, default: {}
  end
end
