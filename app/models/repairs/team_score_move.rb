class Repairs::TeamScoreMove
  include M3::FormObject
  belongs_to :source_team, class_name: 'Team'
  belongs_to :destination_team, class_name: 'Team'

  validates :source_team, :destination_team, presence: true

  def save
    valid?
  end
end
