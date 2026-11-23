# frozen_string_literal: true

# places are checked like teams (list "Neue Wettkampforte"); places with a position count as checked
class AddCheckedAtToPlaces < ActiveRecord::Migration[8.1]
  def up
    add_column :places, :checked_at, :datetime
    execute('UPDATE places SET checked_at = created_at WHERE latitude IS NOT NULL AND longitude IS NOT NULL')
  end

  def down
    remove_column :places, :checked_at
  end
end
