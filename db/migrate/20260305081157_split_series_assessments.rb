# frozen_string_literal: true

class SplitSeriesAssessments < ActiveRecord::Migration[7.2]
  def change
    create_table 'series_team_assessments', id: :serial, force: :cascade do |t|
      t.integer 'round_id', null: false
      t.string 'discipline', limit: 3, null: false
      t.string 'name', limit: 200
      t.string 'key', null: false
      t.timestamps
    end

    create_table 'series_person_assessments', id: :serial, force: :cascade do |t|
      t.integer 'round_id', null: false
      t.string 'discipline', limit: 3, null: false
      t.string 'name', limit: 200
      t.string 'key', null: false
      t.timestamps
    end

    create_table 'series_team_participations', id: :serial, force: :cascade do |t|
      t.integer 'team_assessment_id', null: false
      t.integer 'cup_id', null: false
      t.integer 'team_id', null: false
      t.integer 'team_number', null: false
      t.integer 'team_gender', null: false
      t.integer 'time', null: false
      t.integer 'points', default: 0, null: false
      t.integer 'rank', null: false
      t.timestamps
    end

    create_table 'series_person_participations', id: :serial, force: :cascade do |t|
      t.integer 'person_assessment_id', null: false
      t.integer 'cup_id', null: false
      t.integer 'person_id', null: false
      t.integer 'time', null: false
      t.integer 'points', default: 0, null: false
      t.integer 'rank', null: false
      t.timestamps
    end

    team_assessments = execute <<~SQL.squish
      SELECT * FROM series_assessments WHERE type = 'Series::TeamAssessment'
    SQL

    team_assessments.each do |assessment|
      Series::TeamAssessment.create!(
        id: assessment['id'],
        round_id: assessment['round_id'],
        discipline: assessment['discipline'],
        name: assessment['name'],
        key: assessment['gender'] == 0 ? 'female' : 'male',
      )
    end
    ActiveRecord::Base.connection.execute('ALTER SEQUENCE series_team_assessments_id_seq RESTART WITH 10000')

    person_assessments = execute <<~SQL.squish
      SELECT * FROM series_assessments WHERE type = 'Series::PersonAssessment'
    SQL

    person_assessments.each do |assessment|
      Series::PersonAssessment.create!(
        id: assessment['id'],
        round_id: assessment['round_id'],
        discipline: assessment['discipline'],
        name: [assessment['discipline'], assessment['gender'] == 0 ? 'Frauen' : 'Männer', assessment['name']].compact_blank.join(' - '),
        key: [assessment['gender'] == 0 ? 'female' : 'male', assessment['discipline'], assessment['name']].compact_blank.join('-'),
      )
    end
    ActiveRecord::Base.connection.execute('ALTER SEQUENCE series_person_assessments_id_seq RESTART WITH 10000')

    team_participations = execute <<~SQL.squish
      SELECT * FROM series_participations WHERE type = 'Series::TeamParticipation'
    SQL

    team_participations.each do |participations|
      Series::TeamParticipation.create!(
        id: participations['id'],
        team_assessment_id: participations['assessment_id'],
        cup_id: participations['cup_id'],
        team_id: participations['team_id'],
        team_number: participations['team_number'],
        team_gender: team_assessments.find { |a| a['id'] == participations['assessment_id'] }['gender'],
        time: participations['time'],
        points: participations['points'],
        rank: participations['rank'],
      )
    end
    ActiveRecord::Base.connection.execute('ALTER SEQUENCE series_team_participations_id_seq RESTART WITH 100000')

    person_participations = execute <<~SQL.squish
      SELECT * FROM series_participations WHERE type = 'Series::PersonParticipation'
    SQL

    person_participations.each do |participations|
      Series::PersonParticipation.create!(
        id: participations['id'],
        person_assessment_id: participations['assessment_id'],
        cup_id: participations['cup_id'],
        person_id: participations['person_id'],
        time: participations['time'],
        points: participations['points'],
        rank: participations['rank'],
      )
    end
    ActiveRecord::Base.connection.execute('ALTER SEQUENCE series_person_participations_id_seq RESTART WITH 100000')

    add_index :series_team_assessments, :round_id
    add_index :series_team_assessments, :key
    add_index :series_team_assessments, :discipline
    add_foreign_key :series_team_assessments, :series_rounds, column: :round_id

    add_index :series_team_participations, :team_assessment_id
    add_index :series_team_participations, :cup_id
    add_index :series_team_participations, :team_id
    add_index :series_team_participations, :team_number
    add_foreign_key :series_team_participations, :series_team_assessments, column: :team_assessment_id
    add_foreign_key :series_team_participations, :series_cups, column: :cup_id
    add_foreign_key :series_team_participations, :teams

    add_index :series_person_assessments, :round_id
    add_index :series_person_assessments, :key
    add_index :series_person_assessments, :discipline
    add_foreign_key :series_person_assessments, :series_rounds, column: :round_id

    add_index :series_person_participations, :person_assessment_id
    add_index :series_person_participations, :cup_id
    add_index :series_person_participations, :person_id
    add_foreign_key :series_person_participations, :series_person_assessments, column: :person_assessment_id
    add_foreign_key :series_person_participations, :series_cups, column: :cup_id
    add_foreign_key :series_person_participations, :people

    drop_table :series_participations
    drop_table :series_assessments
  end
end
