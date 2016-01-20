class CreateEntityMerges < ActiveRecord::Migration
  def change
    create_table :entity_merges do |t|
      t.references :source, polymorphic: true, index: true, null: false
      t.references :target, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
