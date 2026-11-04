# frozen_string_literal: true

class PersonSerializer < ApplicationSerializer
  attributes :id, :last_name, :first_name, :gender, :nation_id, :gender_translated
end
