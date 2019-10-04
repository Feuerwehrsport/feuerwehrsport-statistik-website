class AddLongNameToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :long_name, :string, limit: 200
  end
end
