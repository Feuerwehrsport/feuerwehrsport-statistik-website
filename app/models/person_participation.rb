# frozen_string_literal: true

class PersonParticipation < ApplicationRecord
  belongs_to :person
  belongs_to :group_score

  scope :group_score, ->(group_score_id) { where(group_score_id:) }
  scope :person, ->(person_id) { where(person_id:) }
  scope :team, ->(team_id) { joins(:group_score).where(group_scores: { team_id: }) }
  scope :discipline, ->(discipline) { joins(:group_score).merge(GroupScore.discipline(discipline)) }

  validates :position, presence: true
  schema_validations
end
