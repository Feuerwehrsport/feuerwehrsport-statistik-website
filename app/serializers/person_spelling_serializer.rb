class PersonSpellingSerializer < ActiveModel::Serializer
  attributes :person_id, :first_name, :last_name, :gender, :official
end