class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :label
      t.references :linkable, polymorphic: true
      t.text :url

      t.timestamps null: false
    end
  end
end
