# frozen_string_literal: true

class Repairs::TeamScoreMoveDecorator < AppDecorator
  decorates_association :source_team
  decorates_association :destination_team
end
