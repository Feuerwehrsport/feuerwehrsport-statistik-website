class CompetitionTeamNumber < ActiveRecord::Base
  belongs_to :team
  belongs_to :competition
  enum gender: { female: 0, male: 1 }
  scope :gender, -> (gender) { where(gender: CompetitionTeamNumber.genders[gender]) }

  protected

  def readonly?
    true
  end
end
