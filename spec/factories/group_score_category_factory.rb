# frozen_string_literal: true
FactoryBot.define do
  factory :group_score_category do
    group_score_type { GroupScoreType.first || build(:group_score_type) }
    competition { Competition.first || build(:competition) }
    name { 'default' }
  end
end
