class CreateFederalStates < ActiveRecord::Migration
  def change
    create_table :federal_states do |t|
      t.string :name, null: false
      t.string :shortcut, null: false

      t.timestamps null: false
    end

    FederalState.create!(name: 'Baden-Württemberg', shortcut: 'BW')
    FederalState.create!(name: 'Bayern', shortcut: 'BY')
    FederalState.create!(name: 'Berlin', shortcut: 'BE')
    FederalState.create!(name: 'Brandenburg', shortcut: 'BB')
    FederalState.create!(name: 'Bremen', shortcut: 'HB')
    FederalState.create!(name: 'Hamburg', shortcut: 'HH')
    FederalState.create!(name: 'Hessen', shortcut: 'HE')
    FederalState.create!(name: 'Mecklenburg-Vorpommern', shortcut: 'MV')
    FederalState.create!(name: 'Niedersachsen', shortcut: 'NI')
    FederalState.create!(name: 'Nordrhein-Westfalen', shortcut: 'NW')
    FederalState.create!(name: 'Rheinland-Pfalz', shortcut: 'RP')
    FederalState.create!(name: 'Saarland', shortcut: 'SL')
    FederalState.create!(name: 'Sachsen', shortcut: 'SN')
    FederalState.create!(name: 'Sachsen-Anhalt', shortcut: 'ST')
    FederalState.create!(name: 'Schleswig-Holstein', shortcut: 'SH')
    FederalState.create!(name: 'Thüringen', shortcut: 'TH')

    add_column :comp_reg_teams, :federal_state_id, :integer
  end
end
