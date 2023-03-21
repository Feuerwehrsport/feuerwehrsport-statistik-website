# frozen_string_literal: true

class BlaIgnoreToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :ignore_bla_untill_year, :integer
  end
end
