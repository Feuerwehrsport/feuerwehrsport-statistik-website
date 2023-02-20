# frozen_string_literal: true

class TeamMember < ApplicationRecord
  is_view

  belongs_to :team
  belongs_to :person
end
