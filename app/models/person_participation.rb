class PersonParticipation < ActiveRecord::Base
  belongs_to :person
  belongs_to :group_score

  validates :person, :group_score, :position, presence: true
end
