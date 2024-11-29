# frozen_string_literal: true

FactoryBot.define do
  factory :single_discipline do
    initialize_with { SingleDiscipline.find_or_initialize_by(id:) }

    trait(:hl_male) do
      id { 1 }
      key { :hl }
      short_name { 'Hakenleitersteigen' }
      name { 'Hakenleitersteigen (3. Etage)' }
      description { 'Leiter wird vom Start zum Turm getragen. Danach erfolgt der Aufstieg bis in die 3. Etage.' }
      default_for_male { true }
    end

    trait(:hl_female) do
      id { 2 }
      key { :hl }
      short_name { 'Hakenleitersteigen' }
      name { 'Hakenleitersteigen (1. Etage)' }
      description { 'Leiter hängt beim Start im Turm. Es erfolgt der Aufstieg in die 1. Etage.' }
      default_for_female { true }
    end

    trait(:hb_male) do
      id { 3 }
      key { :hb }
      short_name { '100m-Hindernisbahn' }
      name { '100m-Hindernisbahn (Männer)' }
      description do
        'Eine 2m hohe Wand und ein 120cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.'
      end
      default_for_male { true }
    end

    trait(:hb_female) do
      id { 4 }
      key { :hb }
      short_name { '100m-Hindernisbahn' }
      name { '100m-Hindernisbahn (Frauen)' }
      description do
        'Eine Hürde und ein 80cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.'
      end
      default_for_male { true }
    end

    trait(:hb_female_old) do
      id { 5 }
      key { :hb }
      short_name { '100m-Hindernisbahn' }
      name { '100m-Hindernisbahn (Frauen - 120cm Balken)' }
      description do
        'Eine Hürde und ein 120cm hoher Balken müssen überwunden werden. Die Strecke ist 100 Meter lang.'
      end
    end
  end
end
