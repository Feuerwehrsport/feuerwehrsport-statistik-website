# frozen_string_literal: true

class PersonSpellingSerializer < ApplicationSerializer
  attributes :person_id, :first_name, :last_name, :gender, :official, :gender_translated
end
