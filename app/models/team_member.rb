class TeamMember < ActiveRecord::View
  belongs_to :team
  belongs_to :person
end
