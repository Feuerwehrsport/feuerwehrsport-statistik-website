# frozen_string_literal: true

class RemoveAggregateType < ActiveRecord::Migration[7.2]
  def change
    remove_column :series_rounds, :aggregate_type
  end
end
