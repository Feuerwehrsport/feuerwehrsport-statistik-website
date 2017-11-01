FactoryGirl.define do
  factory :person do
    first_name 'Alfred'
    last_name 'Meier'
    gender :male
    nation { Nation.first || build(:nation) }

    trait :female do
      first_name 'Johanna'
      last_name 'Meyer'
      gender :female
    end
  end
end