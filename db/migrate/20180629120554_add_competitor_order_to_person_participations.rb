class AddCompetitorOrderToPersonParticipations < ActiveRecord::Migration
  def change
    add_column :registrations_assessment_participations, :competitor_order, :integer, default: 0, null: false
  end
end
