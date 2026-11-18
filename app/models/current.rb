# frozen_string_literal: true

# per request values (reset by Rails after each request and job)
class Current < ActiveSupport::CurrentAttributes
  # memo of NumberedTeamNames: number of teams per competition, team and gender
  attribute :team_number_counts
end
