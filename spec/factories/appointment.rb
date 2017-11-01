FactoryGirl.define do
  factory :appointment do
    name 'Finale D-Cup in Charlottenthal'
    place { Place.first || build(:place) }
    event { Event.first || build(:event) }
    disciplines 'gs,hb,hl,la'
    dated_at Date.parse('2013-09-21')
    description 'Am 21.09.2013 findet das Finale des Deutschland-Cups in Charlottenthal statt.'
    creator { AdminUser.first || build(:admin_user) }
  end
end