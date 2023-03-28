# frozen_string_literal: true

class Registrations::BandDecorator < AppDecorator
  decorates_association :assessments
  decorates_association :people
  decorates_association :teams
  delegate :to_s, to: :name
end
