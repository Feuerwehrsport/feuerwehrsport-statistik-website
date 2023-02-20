# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :last_name, :first_name, :gender, :nation_id, :gender_translated
end
