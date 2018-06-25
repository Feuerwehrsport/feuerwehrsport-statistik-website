class AddShowOnlyNameToRegistrationsAssessments < ActiveRecord::Migration
  def change
    add_column :registrations_assessments, :show_only_name, :boolean, default: false, null: false
  end
end
