FactoryGirl.define do
  factory :comp_reg_competition, class: CompReg::Competition do
    name "D-Cup"
    date { Date.today }
    place "Ort"
    admin_user { AdminUser.first }
    published true
    group_score true
  end

  factory :comp_reg_team, class: CompReg::Team do
    competition { build(:comp_reg_competition) }
    name "FF Mannschaft"
    shortcut "Mannschaft"
    gender :male
    admin_user { AdminUser.first }
  end

  factory :comp_reg_person, class: CompReg::Person do
    competition { build(:comp_reg_competition) }
    first_name "Alfred"
    last_name "Meier"
    gender :male
    admin_user { AdminUser.first }
  end
end
