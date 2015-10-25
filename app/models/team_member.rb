class TeamMember < ActiveRecord::Base
  belongs_to :team
  belongs_to :person
  
  protected

  def readonly?
    true
  end
end
