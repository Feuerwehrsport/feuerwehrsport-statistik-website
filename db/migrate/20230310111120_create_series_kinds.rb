# frozen_string_literal: true

class CreateSeriesKinds < ActiveRecord::Migration[7.0]
  def change
    create_table :series_kinds do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :series_kinds, :slug, unique: true

    add_column :series_rounds, :kind_id, :bigint
    add_foreign_key :series_rounds, :series_kinds, column: :kind_id

    rounds = execute <<~SQL.squish
      SELECT "series_rounds"."name", "series_rounds"."slug"
      FROM "series_rounds"
      GROUP BY "series_rounds"."name", "series_rounds"."slug"
    SQL

    rounds.each do |round|
      p round

      kind = Series::Kind.create!(
        name: round['name'],
        slug: round['slug'],
      )

      Series::Round.where(
        name: round['name'],
        slug: round['slug'],
      ).update_all(kind_id: kind.id)
    end

    change_table :series_rounds, bulk: true do |t|
      t.remove :name
      t.remove :slug
    end

    add_index :series_rounds, :kind_id
  end
end
