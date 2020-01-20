FactoryBot.define do
  factory :ipo_registration, class: 'Ipo::Registration' do
    team_name { 'Warin' }
    name { 'Limbach, Georg' }
    locality { 'Rostock' }
    phone_number { '0190 123456' }
    email_address { 'georf@georf.de' }
    youth_team { true }
    female_team { false }
    male_team { true }
    terms_of_service { true }
  end
end
