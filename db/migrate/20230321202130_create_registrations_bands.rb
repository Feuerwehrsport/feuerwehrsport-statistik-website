# frozen_string_literal: true

class CreateRegistrationsBands < ActiveRecord::Migration[7.0]
  def change
    create_table :registrations_bands do |t|
      t.string :name, null: false, limit: 200
      t.integer :gender, null: false
      t.references :competition, null: false
      t.integer :position
      t.string :person_tags, default: '', null: false
      t.string :team_tags, default: '', null: false

      t.timestamps
    end

    add_foreign_key :registrations_bands, :registrations_competitions, column: :competition_id

    add_column :registrations_assessments, :band_id, :bigint
    add_foreign_key :registrations_assessments, :registrations_bands, column: :band_id

    add_column :registrations_teams, :band_id, :bigint
    add_foreign_key :registrations_teams, :registrations_bands, column: :band_id

    add_column :registrations_people, :band_id, :bigint
    add_foreign_key :registrations_people, :registrations_bands, column: :band_id

    Registrations::Competition.all.each do |competition|
      band_female = Registrations::Band.create!(
        competition:, name: 'Frauen', gender: 0,
        person_tags: competition.person_tags, team_tags: competition.team_tags
      )
      Registrations::Team.where(competition_id: competition.id, gender: 0).update_all(band_id: band_female.id)
      Registrations::Person.where(competition_id: competition.id, gender: 0).update_all(band_id: band_female.id)
      Registrations::Assessment.where(competition_id: competition.id, gender: 0).update_all(band_id: band_female.id)

      band_male = Registrations::Band.create!(
        competition:, name: 'Männer', gender: 1,
        person_tags: competition.person_tags, team_tags: competition.team_tags
      )
      Registrations::Team.where(competition_id: competition.id, gender: 1).update_all(band_id: band_male.id)
      Registrations::Person.where(competition_id: competition.id, gender: 1).update_all(band_id: band_male.id)
      Registrations::Assessment.where(competition_id: competition.id, gender: 1).update_all(band_id: band_male.id)
    end

    change_table :registrations_teams, bulk: true do |t|
      t.remove :street_with_house_number
      t.remove :postal_code
      t.remove :locality
      t.remove :competition_id
      t.remove :gender
      t.remove :federal_state_id
    end

    change_table :registrations_people, bulk: true do |t|
      t.remove :competition_id
      t.remove :gender
    end

    change_table :registrations_assessments, bulk: true do |t|
      t.remove :competition_id
      t.remove :gender
    end

    change_table :registrations_competitions, bulk: true do |t|
      t.remove :person_tags
      t.remove :team_tags
    end
  end
end
