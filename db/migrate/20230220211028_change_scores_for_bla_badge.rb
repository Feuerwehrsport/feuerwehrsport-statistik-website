# frozen_string_literal: true

class ChangeScoresForBLABadge < ActiveRecord::Migration[5.2]
  def change
    change_table :competitions, bulk: true do |t|
      t.boolean :hb_male_for_bla_badge, default: false, null: false
      t.boolean :hl_male_for_bla_badge, default: false, null: false
      t.boolean :hb_female_for_bla_badge, default: false, null: false
      t.boolean :hl_female_for_bla_badge, default: false, null: false
    end

    execute <<~SQL.squish
      UPDATE competitions SET hb_male_for_bla_badge = 't',
      hl_male_for_bla_badge = 't',
      hb_female_for_bla_badge = 't',
      hl_female_for_bla_badge = 't'#{' '}
      WHERE scores_for_bla_badge = 't'
    SQL

    remove_column :competitions, :scores_for_bla_badge
  end
end
