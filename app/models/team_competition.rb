class TeamCompetition < ActiveRecord::Base
  belongs_to :team
  belongs_to :competition

  protected

  def readonly?
    true
  end
end
