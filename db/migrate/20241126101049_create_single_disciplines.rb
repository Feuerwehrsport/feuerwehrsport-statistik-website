class CreateSingleDisciplines < ActiveRecord::Migration[7.0]
  def change
    create_table :single_disciplines do |t|
      t.string :key, limit: 2, null: false
      t.string :short_name, limit: 100, null: false
      t.string :name, limit: 200, null: false
      t.text :description, null: false
      t.boolean :default_for_male, default: false, null: false
      t.boolean :default_for_female, default: false, null: false

      t.timestamps
    end

    add_column :scores, :single_discipline_id, :bigint

    hl_male = SingleDiscipline.create!(
      key: :hl,
      short_name: "Hakenleitersteigen",
      name: "Hakenleitersteigen (3. Etage)",
      description: "Leiter wird vom Start zum Turm getragen. Danach erfolgt der Aufstieg bis in die 3. Etage.",
      default_for_male: true,
    )

    Score.all.gender(:male).discipline(:hl).update_all(single_discipline_id: hl_male.id)

    hl_female = SingleDiscipline.create!(
      key: :hl,
      short_name: "Hakenleitersteigen",
      name: "Hakenleitersteigen (1. Etage)",
      description: "Leiter hängt beim Start im Turm. Es erfolgt der Aufstieg in die 1. Etage.",
      default_for_female: true,
    )

    Score.all.gender(:female).discipline(:hl).update_all(single_discipline_id: hl_female.id)

    hb_male = SingleDiscipline.create!(
      key: :hb,
      short_name: "100m-Hindernisbahn",
      name: "100m-Hindernisbahn (Männer)",
      description: "Eine 2m hohe Wand und ein 120cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.",
      default_for_male: true,
    )

    Score.all.gender(:male).discipline(:hb).update_all(single_discipline_id: hb_male.id)

    hb_female = SingleDiscipline.create!(
      key: :hb,
      short_name: "100m-Hindernisbahn",
      name: "100m-Hindernisbahn (Frauen)",
      description: "Eine Hürde und ein 80cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.",
      default_for_male: true,
    )

    Score.all.gender(:female).discipline(:hw).update_all(single_discipline_id: hb_female.id)

    hb_female_old = SingleDiscipline.create!(
      key: :hb,
      short_name: "100m-Hindernisbahn",
      name: "100m-Hindernisbahn (Frauen - 120cm Balken)",
      description: "Eine Hürde und ein 120cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.",
    )

    Score.all.gender(:female).discipline(:hb).update_all(single_discipline_id: hb_female_old.id)

    change_column_null :scores, :single_discipline_id, false
    add_index :scores, :single_discipline_id
    add_foreign_key :scores, :single_disciplines
  end
end
