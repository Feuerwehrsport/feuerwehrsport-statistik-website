FactoryBot.define do
  factory :group_score do
    team { Team.first || build(:team) }
    team_number 1
    gender :male
    time 2287
    group_score_category { GroupScoreCategory.first || build(:group_score_category) }

    trait :double do
      after(:create) do |group_score|
        create(:group_score, time: 2345, team: group_score.team, group_score_category: group_score.group_score_category)
      end
    end
  end
end
