FactoryGirl.define do
  factory :change_log do
    admin_user { AdminUser.first || build(:admin_user) }
    model_class 'Person'
    action 'create-person'
    content('after_hash' => {
              'id' => 2953,
              'last_name' => 'Sommer',
              'first_name' => 'Roland',
              'gender' => 'male',
              'nation_id' => 1,
              'gender_translated' => 'männlich',
            })
  end
end
