class CreateCompetitionFiles < ActiveRecord::Migration
  def change
    create_table :competition_files do |t|
      t.references :competition, index: true, foreign_key: true
      t.string :file
      t.string :keys_string

      t.timestamps null: false
    end
  end
end
