# frozen_string_literal: true

class RemoveDisciplineFromScores < ActiveRecord::Migration[7.0]
  def change
    ActiveRecordViews.drop_view connection, 'score_double_events'
    ActiveRecordViews.drop_view connection, 'score_low_double_events'

    remove_column :scores, :discipline
  end
end
