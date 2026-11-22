# frozen_string_literal: true

# fixed key for every type (the code finds types by key, so the names can be changed)
class AddKeyToGroupScoreTypes < ActiveRecord::Migration[8.1]
  KEYS = {
    1 => 'din_zielgeraete', 2 => 'wko', 3 => 'wko_feuer', 4 => 'tgl_zielgeraete', 5 => 'tgl_dose',
    6 => 'wko_abstellen', 7 => 'unbekannt', 8 => 'din_dose', 9 => 'freie_pumpe_zielgeraete', 10 => 'din_zielgeraete_2b',
    11 => 'isffr_c52', 12 => 'isffr', 14 => 'frauen_haus_abstellen', 15 => 'lk_sonneberg', 16 => 'tgl_dose_c52',
    17 => 'din_dose_c52', 18 => 'freie_pumpe_dose', 19 => 'tgl_dose_2b', 20 => 'wko_2023_gas', 21 => 'jugend_bb',
    22 => 'jugend_mv', 23 => 'din_dose_2b', 24 => 'jugend_garitz'
  }.freeze

  def up
    # the column can already exist from an earlier version of this migration
    add_column :group_score_types, :key, :string unless column_exists?(:group_score_types, :key)
    execute('UPDATE group_score_types SET key = NULL')
    KEYS.each { |id, key| execute("UPDATE group_score_types SET key = #{quote(key)} WHERE id = #{id}") }

    # types without a fixed key: derived from the name (with the id if already used)
    select_rows('SELECT id, name FROM group_score_types WHERE key IS NULL').each do |id, name|
      key = I18n.transliterate(name.to_s).downcase.gsub(/[^a-z0-9]+/, '_').delete_prefix('_').delete_suffix('_')
      used = select_value("SELECT 1 FROM group_score_types WHERE key = #{quote(key)}")
      key = "#{key.presence || 'typ'}_#{id}" if used
      execute("UPDATE group_score_types SET key = #{quote(key)} WHERE id = #{id}")
    end

    change_column_null :group_score_types, :key, false
    add_index :group_score_types, :key, unique: true unless index_exists?(:group_score_types, :key)
  end

  def down
    remove_column :group_score_types, :key
  end
end
