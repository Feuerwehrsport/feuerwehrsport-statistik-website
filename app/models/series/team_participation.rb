# frozen_string_literal: true

class Series::TeamParticipation < Series::Participation
  belongs_to :team

  validates :team_number, presence: true

  def entity_id
    "#{team_id}-#{team_number}"
  end
end
