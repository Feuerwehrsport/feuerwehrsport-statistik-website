class AddScoresForBLABadgeToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :scores_for_bla_badge, :boolean, null: false, default: false

    Competition.where(event_id: [1, 5, 12]).update_all(scores_for_bla_badge: true)
  end
end
