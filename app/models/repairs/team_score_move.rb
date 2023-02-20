# frozen_string_literal: true

class Repairs::TeamScoreMove
  include M3::FormObject
  belongs_to :source_team, class_name: 'Team'
  belongs_to :destination_team, class_name: 'Team'

  def save
    valid?
  end
end
